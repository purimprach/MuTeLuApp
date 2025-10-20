import SwiftUI
import CoreLocation

struct SacredPlaceDetailView: View {
    let place: SacredPlace
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // มีอยู่แล้ว
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var memberStore: MemberStore // เพิ่มบรรทัดนี้
    @State private var showDetailSheet = false
    @State private var showContactOptions = false
    @State private var showCheckinAlert = false
    
    @EnvironmentObject var activityStore: ActivityStore   // มีอยู่แล้ว
    @EnvironmentObject var likeStore: LikeStore           // มีอยู่แล้ว
    @EnvironmentObject var bookmarkStore: BookmarkStore     // มีอยู่แล้ว
    
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    @State private var refreshTrigger = UUID()
    @State private var countdownTimer: Timer?
    @State private var timeRemaining: TimeInterval = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                BackButton() // ใช้ BackButton Component
                
                // MARK: - Header Card (ปรับ Action ปุ่ม Like/Bookmark)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Text(language.localized(place.nameTH, place.nameEN))
                            .font(.title2).fontWeight(.bold).multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            // --- 👇 ปุ่ม Bookmark (แก้ไข Action + Label) ---
                            Button {
                                if flowManager.isGuestMode {
                                    flowManager.requireLogin() // บังคับ Login ถ้าเป็น Guest
                                } else {
                                    // ทำ Action ปกติ
                                    memberStore.toggleLike(for: loggedInEmail, place: place)
                                    bookmarkStore.toggleBookmark(placeID: place.id.uuidString, for: loggedInEmail)
                                    // อ่านค่าล่าสุดหลัง toggle
                                    let nowBookmarked = bookmarkStore.isBookmarked(placeID: place.id.uuidString, by: loggedInEmail)
                                    let activityType: ActivityType = nowBookmarked ? .bookmarked : .unbookmarked
                                    let newActivity = ActivityRecord(
                                        type: activityType,
                                        placeID: place.id.uuidString,
                                        placeNameTH: place.nameTH,
                                        placeNameEN: place.nameEN,
                                        memberEmail: loggedInEmail,
                                        date: Date(),
                                        meritPoints: nil // Bookmark ไม่มีแต้ม
                                    )
                                    activityStore.addActivity(newActivity)
                                    // ไม่ต้องใช้ withAnimation กับ State แล้ว
                                }
                            } label: {
                                // อ่านสถานะล่าสุดจาก Store โดยตรง
                                let isCurrentlyBookmarked = bookmarkStore.isBookmarked(placeID: place.id.uuidString, by: loggedInEmail)
                                Image(systemName: isCurrentlyBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.title)
                                    .foregroundColor(isCurrentlyBookmarked ? .blue : .gray)
                                    .scaleEffect(isCurrentlyBookmarked ? 1.2 : 1.0)
                                // เพิ่ม Animation ที่นี่เพื่อให้ Icon ขยับตอน State เปลี่ยน
                                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isCurrentlyBookmarked)
                            }
                            // --- 👆 สิ้นสุด Bookmark ---
                            
                            // --- 👇 ปุ่ม Like (แก้ไข Action + Label) ---
                            Button {
                                if flowManager.isGuestMode {
                                    flowManager.requireLogin() // บังคับ Login ถ้าเป็น Guest
                                } else {
                                    // ทำ Action ปกติ
                                    likeStore.toggleLike(placeID: place.id.uuidString, for: loggedInEmail)
                                    // อ่านค่าล่าสุดหลัง toggle
                                    let nowLiked = likeStore.isLiked(placeID: place.id.uuidString, by: loggedInEmail)
                                    let activityType: ActivityType = nowLiked ? .liked : .unliked
                                    let newActivity = ActivityRecord(
                                        type: activityType,
                                        placeID: place.id.uuidString,
                                        placeNameTH: place.nameTH,
                                        placeNameEN: place.nameEN,
                                        memberEmail: loggedInEmail,
                                        date: Date(),
                                        meritPoints: nil // Like ไม่มีแต้ม
                                    )
                                    activityStore.addActivity(newActivity)
                                    // ไม่ต้องใช้ withAnimation กับ State แล้ว
                                }
                            } label: {
                                // อ่านสถานะล่าสุดจาก Store โดยตรง
                                let isCurrentlyLiked = likeStore.isLiked(placeID: place.id.uuidString, by: loggedInEmail)
                                Image(systemName: isCurrentlyLiked ? "heart.fill" : "heart")
                                    .font(.title)
                                    .foregroundColor(isCurrentlyLiked ? .red : .gray)
                                    .scaleEffect(isCurrentlyLiked ? 1.2 : 1.0)
                                // เพิ่ม Animation ที่นี่เพื่อให้ Icon ขยับตอน State เปลี่ยน
                                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isCurrentlyLiked)
                            }
                            // --- 👆 สิ้นสุด Like ---
                        }
                    }
                    
                    Label(language.currentLanguage == "th" ? place.locationTH : place.locationEN, systemImage: "mappin.and.ellipse")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding().background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // --- ส่วนเนื้อหาอื่นๆ (เหมือนเดิม) ---
                ExpandableTextView(
                    fullText: language.localized(place.descriptionTH, place.descriptionEN),
                    lineLimit: 5
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Image(place.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Button(action: {
                    showDetailSheet.toggle()
                }) {
                    Text(language.localized("ดูรายละเอียด", "View Details"))
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // --- ส่วน Map, Directions, Check-in, Contact ---
                VStack(alignment: .leading, spacing: 15) {
                    MapSnapshotView(
                        latitude: place.latitude,
                        longitude: place.longitude,
                        placeName: place.nameTH
                    )
                    .frame(height: 180)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Button(action: {
                        openInMaps()
                    }) {
                        Label(language.localized("นำทาง", "Get Directions"), systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // --- 👇 ส่วน Check-in (ปรับปรุงเงื่อนไข Guest) ---
                    VStack {
                        // ตรวจสอบสถานะ Check-in เฉพาะเมื่อ Login อยู่ หรือเป็น Guest และอยู่ใกล้
                        let canPotentiallyCheckIn = isUserNearPlace() // อยู่ใกล้หรือไม่
                        let hasCheckedIn = !flowManager.isGuestMode && activityStore.hasCheckedInRecently(email: loggedInEmail, placeID: place.id.uuidString) // Login อยู่ และเพิ่ง Check-in
                        
                        if hasCheckedIn {
                            // แสดงสถานะ Checked-in + Cooldown (เหมือนเดิม)
                            VStack(spacing: 8) {
                                Label(language.localized("เช็คอินแล้ว", "Checked-in"), systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                
                                if timeRemaining > 0 {
                                    Text(language.localized("เช็คอินครั้งถัดไปได้ในอีก:", "Next check-in in:"))
                                    Text(formatTime(timeRemaining))
                                        .font(.system(.headline, design: .monospaced).bold())
                                        .foregroundColor(.orange)
                                } else {
                                    Text(language.localized("สามารถเช็คอินใหม่ได้แล้ว", "Ready to check-in again"))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        } else if canPotentiallyCheckIn {
                            // ถ้าอยู่ใกล้พอ แต่ยังไม่ได้ Check-in หรือ Cooldown หมดแล้ว
                            if flowManager.isGuestMode {
                                // --- แสดงปุ่ม "Login เพื่อ Check-in" ---
                                Button {
                                    flowManager.requireLogin() // บังคับ Login
                                } label: {
                                    Label(language.localized("เข้าสู่ระบบเพื่อเช็คอิน", "Login to Check-in"), systemImage: "lock.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.orange) // ใช้สีอื่น
                                        .cornerRadius(12)
                                }
                            } else {
                                // --- แสดงปุ่ม Check-in ปกติ ---
                                Button {
                                    // Action Check-in ปกติ
                                    let newActivity = ActivityRecord(
                                        type: .checkIn,
                                        placeID: place.id.uuidString,
                                        placeNameTH: place.nameTH,
                                        placeNameEN: place.nameEN,
                                        memberEmail: loggedInEmail,
                                        date: Date(),
                                        meritPoints: 15 // กำหนดแต้มที่นี่
                                    )
                                    activityStore.addActivity(newActivity)
                                    showCheckinAlert = true
                                    refreshTrigger = UUID() // ทำให้ UI รีเฟรช
                                    startCountdownTimer() // เริ่มนับ Cooldown หลัง Check-in สำเร็จ
                                } label: {
                                    Label(language.localized("เช็คอินเพื่อรับแต้ม", "Check-in to earn points"), systemImage: "checkmark.seal.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                                .alert(isPresented: $showCheckinAlert) {
                                    Alert(
                                        title: Text("✅ \(language.localized("สำเร็จ", "Success"))"),
                                        message: Text(language.localized("คุณได้เช็คอินเรียบร้อยแล้ว! รับ 15 แต้ม", "You have checked in! Received 15 points")),
                                        dismissButton: .default(Text(language.localized("ตกลง", "OK")))
                                    )
                                }
                            }
                        } else {
                            // --- แสดงข้อความ "อยู่ไกล" ---
                            Text("📍 \(language.localized("คุณยังอยู่ไกลเกินกว่าจะเช็คอินได้", "You are too far to check-in"))")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .id(refreshTrigger) // ใช้ id เดิมเพื่อ Trigger refresh
                    // --- 👆 สิ้นสุดส่วน Check-in ---
                    
                    // --- ปุ่ม Contact (เหมือนเดิม) ---
                    Button(action: {
                        showContactOptions = true
                    }) {
                        Text("📞 \(language.localized("ติดต่อสถานที่", "Contact Venue"))")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .confirmationDialog(
                        language.localized("ติดต่อสถานที่", "Contact Venue"),
                        isPresented: $showContactOptions,
                        titleVisibility: .visible
                    ) {
                        Button(language.localized("โทร", "Call")) { contactPhone() }
                        Button(language.localized("อีเมล", "Email")) { contactEmail() }
                        Button(language.localized("แอดไลน์", "Add LINE")) { openLine() }
                        Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
                    }
                }
            } // End of main VStack
            .padding(.top)
            
        } // End of ScrollView
        .sheet(isPresented: $showDetailSheet) {
            DetailSheetView(details: place.details)
                .environmentObject(language)
        }
        .onAppear {
            startCountdownTimer() // เริ่ม Timer เมื่อ View ปรากฏ
        }
        .onDisappear {
            stopCountdownTimer() // หยุด Timer เมื่อ View หายไป
        }
        // --- 👇 [เพิ่ม] Alert สำหรับบังคับ Login ---
        .alert(language.localized("ต้องเข้าสู่ระบบ", "Login Required"), isPresented: $flowManager.showLoginPromptAlert) {
            Button(language.localized("เข้าสู่ระบบ / สมัคร", "Login / Register")) {
                flowManager.exitGuestMode() // เรียกฟังก์ชันที่พาไปหน้า Login
            }
            Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {
                // แค่ปิด Alert ไม่ต้องทำอะไรเพิ่ม
            }
        } message: {
            Text(language.localized("ฟังก์ชันนี้สำหรับสมาชิกเท่านั้น โปรดเข้าสู่ระบบหรือสมัครสมาชิกเพื่อใช้งาน", "This feature is available for members only. Please log in or register to continue."))
        }
        // --- 👆 สิ้นสุด ---
    } // End of body
    
    // --- Functions (เหมือนเดิม ไม่มีการเปลี่ยนแปลง) ---
    func isUserNearPlace() -> Bool {
        guard let userLocation = locationManager.userLocation else {
            print("❌ ไม่พบตำแหน่งผู้ใช้")
            return false
        }
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        // ระยะทดสอบ 50 km, ระยะจริงอาจจะ 100-500 เมตร
        return userLocation.distance(from: placeLocation) < 50000 // 50 km for testing
    }
    
    func openInMaps() {
        let latitude = place.latitude
        let longitude = place.longitude
        if let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d") {
            UIApplication.shared.open(url)
        }
    }
    
    func contactPhone() {
        if let url = URL(string: "tel://022183365"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func contactEmail() {
        if let url = URL(string: "mailto:pr@chula.ac.th"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openLine() {
        if let url = URL(string: "https://page.line.me/chulalongkornu"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // --- Timer Functions (แก้ไขเล็กน้อย) ---
    func startCountdownTimer() {
        // หยุด Timer เก่าก่อน ถ้ามี
        stopCountdownTimer()
        // อัปเดตเวลาครั้งแรก
        updateTimeRemaining()
        // เริ่ม Timer ใหม่ ถ้าจำเป็น (timeRemaining > 0)
        if timeRemaining > 0 {
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                updateTimeRemaining()
            }
        }
    }
    
    func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    func updateTimeRemaining() {
        // คำนวณเวลาที่เหลือเฉพาะเมื่อ Login อยู่
        if !flowManager.isGuestMode,
           let remaining = activityStore.timeRemainingUntilNextCheckIn(email: loggedInEmail, placeID: place.id.uuidString) {
            timeRemaining = remaining
            if remaining <= 0 && countdownTimer != nil { // หยุด Timer ถ้าหมดเวลาแล้ว และ Timer ยังทำงานอยู่
                stopCountdownTimer()
                refreshTrigger = UUID() // Refresh UI เผื่อปุ่ม Check-in ต้องเปลี่ยน
            }
        } else {
            timeRemaining = 0 // ถ้าเป็น Guest หรือไม่เคย Check-in
            if countdownTimer != nil { // หยุด Timer ถ้าไม่จำเป็นต้องนับแล้ว
                stopCountdownTimer()
            }
        }
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
} // End of struct

// --- ExpandableTextView (เหมือนเดิม) ---
struct ExpandableTextView: View {
    let fullText: String
    let lineLimit: Int
    @State private var isExpanded = false
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fullText)
                .lineLimit(isExpanded ? nil : lineLimit)
                .animation(.easeInOut, value: isExpanded)
            
            Button(action: {
                isExpanded.toggle()
            }) {
                Text(isExpanded ? language.localized("แสดงน้อยลง", "Show Less") : language.localized("อ่านเพิ่มเติม", "Read More"))
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
        }
    }
}
