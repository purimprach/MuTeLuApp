import SwiftUI
import CoreLocation

struct HomeView: View {
    enum HomeTab: Hashable { case home, notifications, history, profile }
    @EnvironmentObject var sacredPlaceViewModel: SacredPlaceViewModel
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var activityStore: ActivityStore 
    @EnvironmentObject var notificationStore: NotificationStore
    
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    @State private var selectedTab: HomeTab = .home
    @State private var showBanner = false
    @State private var topILPlaces: [SacredPlace] = [] 
    @State private var nearestWithDistance: [(place: SacredPlace, distance: CLLocationDistance)] = []
    @State private var locationUnavailable = false
    @State private var lastComputedLocation: CLLocation?
    @State private var lastComputeAt: Date = .distantPast
    
    private let minMoveMeters: CLLocationDistance = 50
    private let minInterval: TimeInterval = 6
    
    private var currentMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainMenuView(
                showBanner: $showBanner,
                currentMember: flowManager.isGuestMode ? nil : currentMember, // ถ้าเป็น Guest ไม่ต้องส่ง member
                flowManager: flowManager,
                nearest: nearestWithDistance,
                topRated: topILPlaces, // 👈 ส่ง topILPlaces ที่คำนวณ IL แล้ว
                checkProximityToSacredPlaces: checkProximityToSacredPlaces,
                locationManager: locationManager
            )
            .environmentObject(language)
            .environmentObject(flowManager)
            .environmentObject(activityStore)
            .environmentObject(locationManager)
            .overlay(alignment: .top) {
                if locationUnavailable {
                    Text(language.localized("ไม่พบตำแหน่งที่ตั้ง", "Location unavailable"))
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.red.opacity(0.12))
                        .clipShape(Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .tabItem { Label(language.localized("หน้าหลัก", "Home"), systemImage: "house") }
            .tag(HomeTab.home)
            
            NotificationView() // <-- แก้ไขตรงนี้
                .environmentObject(language) // ส่ง EnvironmentObjects ที่จำเป็น
                .environmentObject(flowManager)
                .environmentObject(notificationStore) // ต้องส่ง notificationStore ด้วย
                .environmentObject(sacredPlaceViewModel) // ส่ง ViewModel ด้วย
                .tabItem { Label(language.localized("การแจ้งเตือน", "Notifications"), systemImage: "bell") }
                .tag(HomeTab.notifications)
            
            // --- Tab ประวัติ (History) ---
            HistoryView()
                .environmentObject(language) // ส่ง EnvironmentObjects ที่จำเป็น
                .environmentObject(flowManager)
                .environmentObject(activityStore)
                .tabItem { Label(language.localized("ประวัติ", "History"), systemImage: "clock") }
                .tag(HomeTab.history)
            // --- 👇 [เพิ่ม] ทำให้กดไม่ได้ถ้าเป็น Guest ---
                .disabled(flowManager.isGuestMode)
                .opacity(flowManager.isGuestMode ? 0.5 : 1.0) // ทำให้จางลง
            // --- 👆 สิ้นสุด ---
            
            // --- Tab ข้อมูลของฉัน (Profile) ---
            NavigationStack { ProfileView() } // ProfileView จะจัดการเรื่อง Guest ข้างในเอง
                .environmentObject(language) // ส่ง EnvironmentObjects ที่จำเป็น
                .environmentObject(flowManager)
                .environmentObject(memberStore)
                .environmentObject(activityStore) // ProfileView อาจต้องใช้ activityStore ด้วย
                .tabItem { Label(language.localized("ข้อมูลของฉัน", "Profile"), systemImage: "person.circle") }
                .tag(HomeTab.profile)
            // --- 👇 [เพิ่ม] ทำให้กดไม่ได้ถ้าเป็น Guest ---
                .disabled(flowManager.isGuestMode)
                .opacity(flowManager.isGuestMode ? 0.5 : 1.0)
        }
        .tint(.purple)
        // เรียกครั้งแรกเมื่อหน้าแสดง
        .task {
            // ✅ เรียกคำนวณ IL ก่อน หรือพร้อมๆ กับ computeNearest
            await calculateILRankingForHome()
            await debouncedProximityCompute(force: true)
        }
        // เรียกใหม่เมื่อ location เปลี่ยน (debounce/throttle ภายใน)
        .task(id: locationManager.userLocation) { // ใช้ .task(id:)
            await debouncedProximityCompute()
            // อาจจะคำนวณ IL ใหม่ด้วย ถ้่าข้อมูล activities เปลี่ยน แต่ตอนนี้ยังไม่มี trigger
        }
    }
    
    // ✅ ฟังก์ชันคำนวณ IL Ranking (ที่เพิ่มเข้ามา)
    private func calculateILRankingForHome() async {
        // --- 👇 [แก้ไข] ใช้ viewModel.places ---
        // if sacredPlaces.isEmpty { ... } // <--- ลบออก
        guard !sacredPlaceViewModel.places.isEmpty else { // <--- ใช้ตัวนี้แทน
            print("⚠️ No sacred places loaded for IL Ranking.")
            return
        }
        
        let nilrRecommender = NILR_Recommender(
            members: memberStore.members,
            places: sacredPlaceViewModel.places,
            activities: activityStore.activities
        )
        let (isf, isp) = nilrRecommender.calculateISFAndISP()
        let ilRanked = nilrRecommender.calculateILRanking(isfScores: isf, ispScores: isp)
        
        // อัปเดต State บน Main Thread
        await MainActor.run {
            self.topILPlaces = Array(ilRanked.prefix(3)) // เอา Top 3
            print("🏆 Top IL Places Updated: \(self.topILPlaces.map { language.currentLanguage == "th" ? $0.nameTH : $0.nameEN })")
        }
    }
    
    
    // MARK: - Public trigger
    func checkProximityToSacredPlaces() {
        Task { await debouncedProximityCompute(force: true) }
    }
    
    // MARK: - Debounce/Throttle wrapper
    private func debouncedProximityCompute(force: Bool = false) async {
        guard let userCL = locationManager.userLocation else {
            await MainActor.run { locationUnavailable = true }
            return
        }
        
        // throttle ระยะ + เวลา
        if !force {
            if let last = lastComputedLocation,
               userCL.distance(from: last) < minMoveMeters,
               Date().timeIntervalSince(lastComputeAt) < minInterval {
                return
            }
        }
        
        let result = await computeNearest(from: userCL)
        await MainActor.run {
            self.locationUnavailable = false
            self.lastComputedLocation = userCL
            self.lastComputeAt = Date()
            self.nearestWithDistance = result.nearest
            // self.topRatedPlaces = result.topRated // 👈 ลบบรรทัดนี้ออก เพราะเราใช้ topILPlaces แทนแล้ว
            print("📍 Nearest Places Updated.") // เพิ่ม log ดู
        }
    }
    
    // MARK: - Core compute returns value (ทดสอบง่าย/อัพเดตรวม)
    // MARK: - Core compute returns value (ทดสอบง่าย/อัพเดตรวม)
    private func computeNearest(from userCL: CLLocation) async
    -> (nearest: [(place: SacredPlace, distance: CLLocationDistance)], topRated: [SacredPlace]) {
        guard !sacredPlaceViewModel.places.isEmpty else {
            print("⚠️ No sacred places loaded for Nearest calculation.")
            return (nearest: [], topRated: [])
        }
        let currentPlace = sacredPlaceViewModel.places // ใช้ viewModel ถูกต้องแล้ว
        let linearRank = currentPlace.map { place in
            (place: place,
             d: userCL.distance(from: CLLocation(latitude: place.latitude,
                                                 longitude: place.longitude)))
        }
        let k = min(8, currentPlace.count)
        let topLinearPlaces = Array(linearRank.sorted { $0.d < $1.d }.prefix(k)).map { $0.place }
        
        // 2) ระยะจริงจากเส้นทาง (เหมือนเดิม)
        let routed = await RouteDistanceService.shared.batchDistances(
            from: userCL.coordinate,
            places: topLinearPlaces,
            mode: .driving
        )
        
        // 3) กรองค่า nil + เรียงสั้นสุด (เหมือนเดิม)
        let nearest3 = routed
            .compactMap { r -> (SacredPlace, CLLocationDistance)? in
                guard let d = r.meters else { return nil }
                return (r.place, d)
            }
            .sorted { $0.1 < $1.1 }
        let nearest = Array(nearest3.prefix(3)).map { (place: $0.0, distance: $0.1) }
    
        let topRated = Array(currentPlace.sorted { $0.rating > $1.rating }.prefix(3))
        
        return (nearest, topRated)
    }
}
 
