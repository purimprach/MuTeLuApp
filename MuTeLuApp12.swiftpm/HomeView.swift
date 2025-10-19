import SwiftUI
import CoreLocation

struct HomeView: View {
    enum HomeTab: Hashable { case home, notifications, history, profile }
    
    @StateObject private var viewModel = SacredPlaceViewModel()
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var locationManager: LocationManager
    // @EnvironmentObject var checkInStore: CheckInStore // CheckInStore อาจไม่จำเป็นต้องใช้ตรงนี้แล้ว ถ้า activityStore ครอบคลุม
    @EnvironmentObject var activityStore: ActivityStore // ✅ เพิ่ม activityStore ที่นี่
    
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    @State private var selectedTab: HomeTab = .home
    @State private var showBanner = false
    @State private var topILPlaces: [SacredPlace] = [] // State สำหรับ IL Ranking
    
    // ส่งให้ MainMenuView
    @State private var nearestWithDistance: [(place: SacredPlace, distance: CLLocationDistance)] = []
    // @State private var topRatedPlaces: [SacredPlace] = [] // ลบ State เดิมนี้ออก
    
    // สถานะคุมการคำนวณ
    @State private var locationUnavailable = false
    @State private var lastComputedLocation: CLLocation?
    @State private var lastComputeAt: Date = .distantPast
    
    // ✅ โหลด sacredPlaces ที่นี่เพื่อให้แน่ใจว่ามีข้อมูลเมื่อคำนวณ IL
    // หรือจะโหลดใน viewModel ก็ได้ แต่ต้องแน่ใจว่าโหลดเสร็จก่อนเรียก calculateILRankingForHome
    private let sacredPlaces: [SacredPlace] = loadSacredPlaces() // โหลดข้อมูล
    
    private let minMoveMeters: CLLocationDistance = 50
    private let minInterval: TimeInterval = 6
    
    private var currentMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainMenuView(
                showBanner: $showBanner,
                currentMember: currentMember,
                flowManager: flowManager,
                nearest: nearestWithDistance,
                topRated: topILPlaces, // 👈 ส่ง topILPlaces ที่คำนวณ IL แล้ว
                checkProximityToSacredPlaces: checkProximityToSacredPlaces,
                locationManager: locationManager
            )
            .environmentObject(language)
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
            
            NotificationView()
                .tabItem { Label(language.localized("การแจ้งเตือน", "Notifications"), systemImage: "bell") }
                .tag(HomeTab.notifications)
            
            HistoryView()
                .tabItem { Label(language.localized("ประวัติ", "History"), systemImage: "clock") }
                .tag(HomeTab.history)
            
            NavigationStack { ProfileView() }
                .tabItem { Label(language.localized("ข้อมูลของฉัน", "Profile"), systemImage: "person.circle") }
                .tag(HomeTab.profile)
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
        // ใช้ sacredPlaces ที่โหลดไว้แล้ว
        if sacredPlaces.isEmpty {
            print("⚠️ No sacred places loaded for IL Ranking.")
            return
        }
        
        let nilrRecommender = NILR_Recommender(
            members: memberStore.members,
            places: sacredPlaces, // ใช้ข้อมูลที่โหลดไว้
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
    private func computeNearest(from userCL: CLLocation) async
    -> (nearest: [(place: SacredPlace, distance: CLLocationDistance)], topRated: [SacredPlace]) { // 👈 ยังคง return topRated เดิมไปก่อน เผื่อมีการใช้งานที่อื่น หรือจะลบออกก็ได้ถ้าแน่ใจว่าไม่ได้ใช้แล้ว
        
        // 1) ระยะเส้นตรง
        // ใช้ sacredPlaces ที่โหลดไว้แล้ว
        guard !sacredPlaces.isEmpty else {
            print("⚠️ No sacred places loaded for Nearest calculation.")
            return (nearest: [], topRated: [])
        }
        let linearRank = sacredPlaces.map { place in
            (place: place,
             d: userCL.distance(from: CLLocation(latitude: place.latitude,
                                                 longitude: place.longitude)))
        }
        let k = min(8, sacredPlaces.count)
        let topLinearPlaces = Array(linearRank.sorted { $0.d < $1.d }.prefix(k)).map { $0.place }
        
        // 2) ระยะจริงจากเส้นทาง
        let routed = await RouteDistanceService.shared.batchDistances(
            from: userCL.coordinate,
            places: topLinearPlaces,
            mode: .driving
        )
        
        // 3) กรองค่า nil + เรียงสั้นสุด
        let nearest3 = routed
            .compactMap { r -> (SacredPlace, CLLocationDistance)? in
                guard let d = r.meters else { return nil }
                return (r.place, d)
            }
            .sorted { $0.1 < $1.1 }
        let nearest = Array(nearest3.prefix(3)).map { (place: $0.0, distance: $0.1) }
        
        // 4) รีวิวสูงสุด (คำนวณไว้เผื่อใช้ แต่ไม่ได้อัปเดต state โดยตรงแล้ว)
        let topRated = Array(sacredPlaces.sorted { $0.rating > $1.rating }.prefix(3))
        
        return (nearest, topRated)
    }
}

// Struct NotificationView (ย้ายไปไฟล์แยก หรือไว้ข้างนอก struct HomeView)
struct NotificationView: View {
    var body: some View {
        Text("Notification Screen")
            .font(.headline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }
}
