import SwiftUI
import CoreLocation
import Combine
import MapKit

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Main View: RecommenderForYouView
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
struct RecommenderForYouView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // รับ flowManager มาใช้
    @EnvironmentObject private var memberStore: MemberStore
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @StateObject private var sacredPlaceViewModel = SacredPlaceViewModel() // ใช้ load ข้อมูลสถานที่
    
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    @StateObject private var loc = LocationProvider() // สำหรับ LocationProvider (ถ้าจำเป็น)

    private var activeMember: Member? { 
        guard !flowManager.isGuestMode else { return nil }
        return memberStore.members.first { $0.email.lowercased() == loggedInEmail.lowercased() }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // --- Header ---
                BackButton() // ปุ่ม BackButton ที่แก้ไขแล้ว
                HStack {
                    Text(language.localized("สำหรับคุณ", "For You"))
                        .font(.title2.bold())
                }
                .padding(.horizontal) // ใช้ padding(.horizontal) แทน padding(.horizontal, 16)
                .padding(.top, 8)
                
                // --- Banners (เหมือนเดิม) ---
                BuddhistDayBanner()
                    .environmentObject(language) // ส่ง language
                ReligiousHolidayBanner()
                    .environmentObject(language) // ส่ง language
                
                if !flowManager.isGuestMode {
                    BookmarkedPlacesCard(
                        placesViewModel: sacredPlaceViewModel,
                        bookmarkStore: bookmarkStore,
                        flowManager: flowManager,
                        loggedInEmail: loggedInEmail
                    )
                    .environmentObject(language)
                }
                
                // --- Hero Cards ---
                Group {
                    // Today's Temple Banner
                    TempleBannerCard(
                        headingTH: "แนะนำวัดเหมาะกับวันนี้",
                        headingEN: "Today’s Temple",
                        memberOverride: nil, // ใช้ nil เพื่อให้ getRecommendedTemple ใช้ Date() ปัจจุบัน
                        openDetail: {
                            if flowManager.isGuestMode {
                                let temple = getRecommendedTemple(for: nil)
                                if let place = sacredPlaceViewModel.places.first(where: { $0.nameTH == temple.nameTH || $0.nameEN == temple.nameEN }) {
                                    flowManager.navigateTo(.sacredDetail(place: place))
                                }
                            } else {
                                flowManager.navigateTo(.recommendation)
                            }
                        }
                    )
                    .environmentObject(language)
                    .environmentObject(loc) // ส่ง LocationProvider ถ้าจำเป็น
                    
                    if !flowManager.isGuestMode {
                        // Birthday Temple Banner (ถ้า Login อยู่ และมีวันเกิด)
                        if let member = activeMember, let heading = birthdayHeading(for: member) {
                            TempleBannerCard(
                                headingTH: heading.th,
                                headingEN: heading.en,
                                memberOverride: member, // ส่ง member เข้าไป
                                openDetail: {
                                    // Action เหมือน Today's Temple (ถ้า Login อยู่)
                                    flowManager.navigateTo(.recommendation)
                                }
                            )
                            .environmentObject(language)
                            .environmentObject(loc)
                        } else if activeMember != nil { // Login อยู่ แต่ไม่มีวันเกิดใน Profile
                            // การ์ดแจ้งให้เพิ่มวันเกิด
                            MissingBirthdayCard {
                                flowManager.navigateTo(.editProfile)
                            }
                            .environmentObject(language)
                        }
                        // ไม่ต้องมี else สำหรับ Guest เพราะเราเช็ค if !flowManager.isGuestMode ไปแล้ว
                    }
                }
                
                Spacer(minLength: 12) // ใช้ Spacer แทน padding(.bottom) ที่อาจไม่เห็นผล
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        // Load ข้อมูลสถานที่เมื่อ View ปรากฏ
        .onAppear {
            if sacredPlaceViewModel.places.isEmpty {
                sacredPlaceViewModel.loadPlaces()
            }
        }
    }
    
    // MARK: - Helpers (เหมือนเดิม)
    private func birthdayHeading(for member: Member?) -> (th: String, en: String)? {
        guard let bday = member?.birthdate else { return nil }
        let (th, en) = weekdayName(for: bday)
        return ("แนะนำวัดที่เหมาะกับคนเกิดวัน\(th)", "Recommended Temple for \(en)-born")
    }
    
    private func weekdayName(for date: Date) -> (th: String, en: String) {
        let w = Calendar(identifier: .gregorian).component(.weekday, from: date) // 1=Sun..7=Sat
        let ths = ["อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัส","ศุกร์","เสาร์"]
        let ens = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let i = max(1, min(7, w)) - 1 // ปรับ index ให้ถูกต้อง (0-6)
        return (ths[i], ens[i])
    }
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Subview: BookmarkedPlacesCard (แก้ไข action)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
private struct BookmarkedPlacesCard: View {
    @ObservedObject var placesViewModel: SacredPlaceViewModel
    @ObservedObject var bookmarkStore: BookmarkStore
    var flowManager: MuTeLuFlowManager // รับ flowManager มาใช้
    let loggedInEmail: String
    
    @EnvironmentObject var language: AppLanguage
    
    var bookmarkedRecords: [BookmarkRecord] {
        bookmarkStore.getBookmarks(for: loggedInEmail)
    }
    
    var body: some View {
        // แสดงการ์ดนี้เฉพาะเมื่อมีรายการที่บันทึกไว้
        if !bookmarkedRecords.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                // --- Header ของการ์ด ---
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.blue)
                    Text(language.localized("รายการที่บันทึกไว้", "Saved Places"))
                    Spacer()
                    Button(language.localized("ดูทั้งหมด", "See All")) {
                        // --- 👇 แก้ไขจุดที่ 1 ---
                        flowManager.navigateTo(.bookmarks) // ใช้ navigateTo
                        // --- 👆 สิ้นสุดส่วนแก้ไข ---
                    }
                    .font(.subheadline)
                    .foregroundColor(.purple) // ทำให้ปุ่มเด่นขึ้น
                }
                .font(.headline) // ทำให้ Header ใหญ่ขึ้นเล็กน้อย
                // .foregroundColor(.secondary) // เอาออก เพื่อให้ใช้สีตาม .headline
                
                // --- Horizontal Scroll View ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // ใช้ prefix(5) เพื่อแสดงแค่ 5 รายการแรก (ถ้าต้องการจำกัด)
                        ForEach(bookmarkedRecords.prefix(5)) { record in
                            // หาข้อมูล place จาก viewModel
                            if let place = placesViewModel.places.first(where: { $0.id.uuidString == record.placeID }) {
                                BookmarkItem(place: place)
                                    .onTapGesture {
                                        // --- 👇 แก้ไขจุดที่ 2 ---
                                        flowManager.navigateTo(.sacredDetail(place: place)) // ใช้ navigateTo
                                        // --- 👆 สิ้นสุดส่วนแก้ไข ---
                                    }
                                    .environmentObject(language) // ส่ง language ให้ item
                            }
                        }
                    }
                    .padding(.vertical, 4) // เพิ่ม padding เล็กน้อย
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.primary.opacity(0.06), lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            .padding(.horizontal) // เพิ่ม padding ซ้ายขวาให้การ์ด
        }
        // ไม่ต้องมี else เพราะถ้าไม่มีรายการ ก็ไม่ต้องแสดงการ์ดนี้เลย
    }
}

// MARK: - Subview: BookmarkItem (ปรับปรุงเล็กน้อย)
private struct BookmarkItem: View {
    let place: SacredPlace
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) { // ลด spacing
            Image(uiImage: UIImage(named: place.imageName) ?? UIImage(systemName: "photo")!) // Placeholder
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 80) // ปรับขนาดเล็กน้อย
                .cornerRadius(10)
                .clipped()
                .foregroundColor(.gray) // สี placeholder
            
            Text(language.localized(place.nameTH, place.nameEN))
                .font(.caption.bold()) // ใช้ caption ตัวหนา
                .lineLimit(1)
                .frame(width: 140, alignment: .leading) // จัดชิดซ้าย
            // ไม่ต้อง .padding(.bottom, 4) ถ้า spacing พอดีแล้ว
        }
    }
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Subviews เดิม (TempleBannerCard, MissingBirthdayCard, LocationProvider)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// (โค้ดส่วนนี้ไม่มีการเปลี่ยนแปลง นอกจากรับ EnvironmentObject เพิ่ม)

private struct TempleBannerCard: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var loc: LocationProvider // ใช้ loc ถ้าต้องการแสดงระยะทาง
    var headingTH: String
    var headingEN: String
    var memberOverride: Member?
    var openDetail: () -> Void // action ถูกส่งมาจากข้างนอกแล้ว
    
    var body: some View {
        // หา temple ที่แนะนำ (ใช้ helper function เดิม)
        let temple = getRecommendedTemple(for: memberOverride)
        
        VStack(alignment: .leading, spacing: 10) {
            // Header (เหมือนเดิม)
            HStack(spacing: 8) {
                Image(systemName: "sparkles") // หรือ icon อื่นที่เหมาะสม
                Text(language.localized(headingTH, headingEN))
            }
            .font(.headline) // ทำให้ Header ใหญ่ขึ้นเล็กน้อย
            // .foregroundColor(.secondary) // เอาออก
            
            ZStack(alignment: .bottomLeading) {
                bannerImage(named: temple.imageName) // ใช้ helper เดิม
                    .frame(maxWidth: .infinity) // ทำให้เต็มความกว้าง
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Gradient overlay (เหมือนเดิม)
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.65)], // ทำให้เข้มขึ้นเล็กน้อย
                    startPoint: .center, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .allowsHitTesting(false) // ไม่ให้บังการกด
                
                // Text overlay (เหมือนเดิม)
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.localized(temple.nameTH, temple.nameEN))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .shadow(radius: 1) // เพิ่มเงาให้ Text
                    
                    Text(language.localized(temple.descTH, temple.descEN))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(2)
                        .shadow(radius: 1) // เพิ่มเงาให้ Text
                }
                .padding(14)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // กำหนดรูปร่างที่กดได้
            .onTapGesture(perform: openDetail) // เรียก action ที่ส่งเข้ามา
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .padding(.horizontal) // เพิ่ม padding ซ้ายขวาให้การ์ด
    }
    
    // bannerImage helper (เหมือนเดิม)
    @ViewBuilder
    private func bannerImage(named: String) -> some View {
        if let uiImage = UIImage(named: named) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            ZStack {
                LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(.white.opacity(0.8)) // ใช้ photo.fill
            }
            // ไม่ต้อง .scaledToFill() ที่นี่ เพราะ ZStack จะขยายตาม context
        }
    }
    
    // distanceString helper (เหมือนเดิม) - ใช้ถ้าต้องการแสดงระยะทาง
    private func distanceString(to dest: CLLocation?) -> String? {
        guard let destCoord = dest?.coordinate, let hereCoord = loc.lastLocation?.coordinate else { return nil }
        let placeLocation = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)
        let userLocation = CLLocation(latitude: hereCoord.latitude, longitude: hereCoord.longitude)
        let meters = userLocation.distance(from: placeLocation)
        
        let formatter = MKDistanceFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: meters)
    }
}

private struct MissingBirthdayCard: View {
    @EnvironmentObject var language: AppLanguage
    var onEditProfile: () -> Void // action ถูกส่งมาจากข้างนอก
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(language.localized("ยังไม่มีวันเกิดในโปรไฟล์", "Birthday not set in profile")) // แก้ไขข้อความเล็กน้อย
            } icon: {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(.orange) // เปลี่ยนสีไอคอน
            }
            .font(.headline)
            
            Text(language.localized("เพิ่มวันเกิดเพื่อรับคำแนะนำวัดที่ตรงกับวันเกิดของคุณ", "Add your birthday to get personalized temple recommendations based on your birth day.")) // แก้ไขข้อความเล็กน้อย
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: onEditProfile) { // เรียก action ที่ส่งเข้ามา
                Text(language.localized("ไปที่หน้าแก้ไขโปรไฟล์", "Go to Edit Profile")) // เปลี่ยนข้อความปุ่ม
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.orange) // ใช้สีส้มล้วน อาจจะดูดีกว่า .opacity
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // ใช้ .continuous
            }
            .padding(.top, 5) // เพิ่มระยะห่างบนปุ่ม
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .padding(.horizontal) // เพิ่ม padding ซ้ายขวาให้การ์ด
    }
}

// LocationProvider (เหมือนเดิม)
final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocation?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters // อาจปรับปรุงความแม่นยำถ้าจำเป็น
        manager.requestWhenInUseAuthorization() // ขออนุญาต
        // ควรเริ่ม update location เมื่อจำเป็น หรือตาม lifecycle ของ View
        // manager.startUpdatingLocation() // การเรียกตรงนี้อาจเปลืองแบตถ้า View ไม่ได้แสดงตลอด
    }
    
    // ควรเพิ่มฟังก์ชัน start/stop updating location
    func startUpdating() {
        manager.requestWhenInUseAuthorization() // ขออนุญาตอีกครั้งเผื่อยังไม่ได้ให้
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ใช้ last location ที่มีความแม่นยำพอสมควร
        lastLocation = locations.last // อาจจะต้องกรอง location ที่เก่าหรือแม่นยำน้อยออกไป
        // print("Location updated: \(lastLocation?.coordinate)") // สำหรับ debug
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager failed with error: \(error.localizedDescription)")
        // อาจจะต้องแจ้งเตือนผู้ใช้หรือจัดการ UI ถ้าตำแหน่งใช้งานไม่ได้
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // จัดการเมื่อผู้ใช้เปลี่ยน permission
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location authorized.")
            startUpdating() // เริ่ม update เมื่อได้รับอนุญาต
        case .denied, .restricted:
            print("Location denied or restricted.")
            // แจ้งเตือนผู้ใช้ว่าฟีเจอร์เกี่ยวกับตำแหน่งจะใช้ไม่ได้
            lastLocation = nil // ล้างตำแหน่งเก่า
        case .notDetermined:
            print("Location not determined.")
            manager.requestWhenInUseAuthorization() // ขออนุญาตอีกครั้ง
        @unknown default:
            fatalError("Unknown location authorization status.")
        }
    }
}

