import SwiftUI
import MapKit

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Main View: RecommendationView
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
struct RecommendationView: View {
    @EnvironmentObject var sacredPlaceViewModel: SacredPlaceViewModel
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var activityStore: ActivityStore // ✅ ตรวจสอบว่ามี EnvironmentObject นี้
    @EnvironmentObject var memberStore: MemberStore     // ✅ ตรวจสอบว่ามี EnvironmentObject นี้

    @AppStorage("loggedInEmail") var loggedInEmail: String = ""

    @State private var recommendedPlaces: [SacredPlace] = []
    @State private var routeDistances: [UUID: CLLocationDistance] = [:]

    // --- 2. Body ---
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackButton()

                Text(language.localized("สถานที่แนะนำ", "Recommended Places"))
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if !recommendedPlaces.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(language.localized("แนะนำสำหรับคุณโดยเฉพาะ", "Specially Recommended for You"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(recommendedPlaces) { place in
                            PlaceRow(place: place, routeDistance: routeDistances[place.id])
                        }
                    }
                    Divider().padding()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(language.localized("สถานที่ทั้งหมด", "All Places"))
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(sacredPlaceViewModel.places) { place in
                        PlaceRow(place: place, routeDistance: routeDistances[place.id])
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            generateRecommendations() // เรียก generateRecommendations ตอน View ปรากฏ
            Task { await calculateAllRouteDistances() }
        }
        .onChange(of: locationManager.userLocation) { // ใช้ onChange(of:) แบบใหม่
            Task { await calculateAllRouteDistances() }
        }
    }

    // --- 3. Functions ---
    private func generateRecommendations() {
        // --- ส่วนที่ 1: สร้างโปรไฟล์ความสนใจส่วนตัว (เหมือนเดิม) ---
        var userProfile: [String: Int] = [:]
        let userActivities = activityStore.activities(for: loggedInEmail)

        for activity in userActivities {
            if let place = sacredPlaceViewModel.places.first(where: { $0.id.uuidString == activity.placeID }) {
                let score: Int
                switch activity.type {
                case .checkIn: score = 10
                case .bookmarked: score = 5
                case .liked: score = 3
                case .unliked, .unbookmarked: score = -2
                }
                for tag in place.tags {
                    userProfile[tag, default: 0] += score
                }
            }
        }

        // --- ส่วนที่ 2: เลือกระบบแนะนำ ---
        let allVisitedIDs = activityStore.checkInRecords(for: loggedInEmail).map { UUID(uuidString: $0.placeID) }.compactMap { $0 }

        // สร้าง instance ของ NILRRecommender
        // ตรวจสอบให้แน่ใจว่า viewModel.places มีข้อมูลแล้ว
        guard !sacredPlaceViewModel.places.isEmpty else {
             print("⚠️ Places data not loaded yet. Cannot generate recommendations.")
             self.recommendedPlaces = [] // ตั้งค่าเป็น array ว่างถ้าไม่มีข้อมูล
             return
        }

        let nilrRecommender = NILR_Recommender(
            members: memberStore.members, 
            places: sacredPlaceViewModel.places,     
            activities: activityStore.activities 
        )

        // **เงื่อนไข**: ถ้ามีโปรไฟล์ความสนใจ (เคยมีกิจกรรม) ให้ใช้ระบบแนะนำแบบ Content-based (ตาม Tag) + IL Ranking
        if !userProfile.isEmpty {
            print("👤 Generating recommendations based on User Profile + IL Fallback")
            let engine = RecommendationEngine(places: sacredPlaceViewModel.places) 
            // แนะนำจาก Profile ก่อน
            let profileBasedRecs = engine.getRecommendations(for: userProfile, excluding: allVisitedIDs, top: 3)

            // ถ้า Profile ยังแนะนำได้ไม่ครบ 3 ที่ ให้เติมด้วย IL Ranking
            if profileBasedRecs.count < 3 {
                 print("   Profile recs count (\(profileBasedRecs.count)) < 3, filling with IL Ranking...")
                 let (isf, isp) = nilrRecommender.calculateISFAndISP() // ใช้ชื่อฟังก์ชันใหม่
                 let ilRanked = nilrRecommender.calculateILRanking(isfScores: isf, ispScores: isp)
                 let existingIDs = Set(profileBasedRecs.map { $0.id })
                 let additionalRecs = ilRanked.filter { !allVisitedIDs.contains($0.id) && !existingIDs.contains($0.id) }.prefix(3 - profileBasedRecs.count)
                 self.recommendedPlaces = profileBasedRecs + additionalRecs
            } else {
                 self.recommendedPlaces = profileBasedRecs
            }

        }
        // **เงื่อนไข**: ถ้ายังไม่มีโปรไฟล์ (เป็นผู้ใช้ใหม่) ให้ใช้ระบบ NILR (IL Ranking)
        else {
            print("✨ Generating recommendations based on IL Ranking (New User)")
            // คำนวณ ISF และ ISP
            let (isf, isp) = nilrRecommender.calculateISFAndISP() // ใช้ชื่อฟังก์ชันใหม่
            // คำนวณ IL Ranking
            let ilRankedPlaces = nilrRecommender.calculateILRanking(isfScores: isf, ispScores: isp)
            // เอา Top 3 ที่ยังไม่เคยไป
            self.recommendedPlaces = Array(ilRankedPlaces.filter { !allVisitedIDs.contains($0.id) }.prefix(3))
        }

        print("🏆 Recommended Places: \(self.recommendedPlaces.map { language.currentLanguage == "th" ? $0.nameTH : $0.nameEN } )")
    }
    // --- 👆 สิ้นสุดฟังก์ชัน generateRecommendations ---


    // (ฟังก์ชัน calculateAllRouteDistances เหมือนเดิม)
    private func calculateAllRouteDistances() async {
        guard let userLocation = locationManager.userLocation else { return }

        guard !sacredPlaceViewModel.places.isEmpty else {
             print("⚠️ Places data not loaded for distance calculation.")
             return
        }

        let placesToCalculate = sacredPlaceViewModel.places
        let results = await RouteDistanceService.shared.batchDistances(
            from: userLocation.coordinate,
            places: placesToCalculate,
            mode: .driving
        )

        var newDistances: [UUID: CLLocationDistance] = [:]
        for result in results {
            newDistances[result.place.id] = result.meters
        }

        // ใช้ MainActor.run เพื่ออัปเดต UI บน main thread
        await MainActor.run {
             self.routeDistances = newDistances
        }
    }
}

// (Subviews: PlaceRow และ chip ไม่มีการเปลี่ยนแปลง)
struct PlaceRow: View {
    let place: SacredPlace
    let routeDistance: CLLocationDistance?

    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // รับ flowManager มาใช้

    var body: some View {
        Button(action: {
            // --- 👇 แก้ไขตรงนี้ ---
            flowManager.navigateTo(.sacredDetail(place: place)) // ใช้ navigateTo
            // --- 👆 สิ้นสุดส่วนแก้ไข ---
        }) {
            HStack(spacing: 16) {
                // ส่วนแสดงรูปภาพ (เหมือนเดิม)
                if UIImage(named: place.imageName) != nil {
                    Image(place.imageName)
                        .resizable().scaledToFill()
                        .frame(width: 90, height: 100).cornerRadius(10).clipped()
                } else {
                    // Placeholder ถ้าไม่มีรูป
                    Image(systemName: "photo.fill") // ใช้ photo.fill จะเห็นชัดกว่า
                        .resizable().scaledToFit() // ใช้ scaledToFit สำหรับ placeholder
                        .frame(width: 90, height: 100)
                        .cornerRadius(10)
                        .clipped()
                        .foregroundColor(.gray.opacity(0.3)) // สี placeholder
                        .background(Color(.systemGray5)) // พื้นหลัง placeholder
                }

                // ส่วนแสดงข้อความ (เหมือนเดิม)
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.localized(place.nameTH, place.nameEN))
                        .font(.subheadline).bold() // ทำชื่อตัวหนาเล็กน้อย
                        .foregroundColor(.primary) // ใช้ primary color
                        .lineLimit(2) // จำกัด 2 บรรทัด

                    Text(language.localized(place.locationTH, place.locationEN))
                        .font(.caption).foregroundColor(.gray).lineLimit(2)

                    HStack(spacing: 8) {
                        if let distance = routeDistance {
                            // แสดงระยะทาง (ใช้ฟังก์ชัน chip เดิม)
                            chip(text: formatDistance(distance), icon: "car.fill")
                        } else {
                            // แสดงสถานะกำลังโหลดหรือหาตำแหน่งไม่ได้
                            chip(text: language.localized("กำลังคำนวณ...", "Calculating..."), icon: "location.north.line.fill")
                                .opacity(0.6) // ทำให้จางลงเล็กน้อย
                        }
                        // แสดงเรตติ้ง (ใช้ฟังก์ชัน chip เดิม)
                        chip(text: String(format: "%.1f", place.rating), icon: "star.fill")
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground)) // ใช้สีพื้นหลังรอง
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal) // ระยะห่างซ้ายขวา
        }
        .buttonStyle(.plain) // ทำให้กดได้ทั้งแถวและไม่มี effect แปลกๆ
    }

    // formatDistance function (เหมือนเดิม)
    private func formatDistance(_ meters: CLLocationDistance) -> String {
        let formatter = MKDistanceFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US") // ใช้อิงตามภาษาแอป
        formatter.unitStyle = .abbreviated
        // อาจจะเพิ่มเงื่อนไขแสดงผลต่างกันถ้าระยะทางน้อยมาก
        // if meters < 100 { return "< 100 m" }
        return formatter.string(fromDistance: meters)
    }
}


private func chip(text: String, icon: String) -> some View {
    HStack(spacing: 4) {
        Image(systemName: icon)
        Text(text)
    }
    .font(.caption).bold()
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Color(.tertiarySystemBackground))
    .clipShape(Capsule())
    .foregroundColor(.orange)
}
#Preview {
    // สร้าง Mock Objects ที่จำเป็น
    let mockLanguage = AppLanguage()
    let mockFlowManager = MuTeLuFlowManager()
    let mockLocationManager = LocationManager()
    let mockActivityStore = ActivityStore()
    let mockMemberStore = MemberStore()
    let mockSacredPlaceViewModel = SacredPlaceViewModel() // สร้าง Mock ViewModel
    
    return RecommendationView()
        .environmentObject(mockLanguage)
        .environmentObject(mockFlowManager)
        .environmentObject(mockLocationManager)
        .environmentObject(mockActivityStore)
        .environmentObject(mockMemberStore)
        .environmentObject(mockSacredPlaceViewModel) // ส่ง Mock ViewModel
}
