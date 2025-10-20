import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // 👈 เพิ่มเข้ามา
    @EnvironmentObject var memberStore: MemberStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // --- 👇 [แก้ไข] ลบ EnvironmentObject checkInStore ที่ไม่ได้ใช้ออก ---
    // @EnvironmentObject var checkInStore: CheckInStore // <--- ลบออก
    @EnvironmentObject var activityStore: ActivityStore // ✅ ใช้ตัวนี้แทน (ถ้าจำเป็น)
    // --- 👆 สิ้นสุด ---
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showLogoutAlert = false
    
    // --- 👇 [แก้ไข] ลบ State userRecords ที่ไม่ได้ใช้ออก ---
    // @State private var userRecords: [CheckInRecord] = [] // <--- ลบออก
    // --- 👆 สิ้นสุด ---
    
    
    var currentUser: Member? {
        memberStore.members.first { $0.email.lowercased() == loggedInEmail.lowercased() }
    }
    
    var imageKey: String {
        "profileImage_\(loggedInEmail.lowercased())"
    }
    
    var body: some View {
        // --- 👇 [เพิ่ม] เช็ค Guest Mode ---
        if flowManager.isGuestMode {
            GuestLoginPromptView() // แสดง View สำหรับ Guest
        } else {
            // --- แสดง Profile ปกติ (โค้ดเดิม) ---
            ScrollView {
                VStack(spacing: 20) {
                    // 📷 รูปโปรไฟล์ (เหมือนเดิม)
                    VStack(spacing: 10) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        } else {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text(language.localized("เลือกรูปภาพ", "Select Image"))
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // 🧾 ข้อมูลผู้ใช้ (เหมือนเดิม)
                    if let user = currentUser {
                        SectionTitle(titleTH: "ข้อมูลส่วนตัว", titleEN: "Personal Info")
                        InfoDisplay(title: language.localized("ชื่อ-สกุล", "Full Name"), value: user.fullName)
                        InfoDisplay(title: language.localized("เพศ", "Gender"), value: user.gender)
                        InfoDisplay(title: language.localized("วันเดือนปีเกิด", "Birthdate"), value: formattedDate(user.birthdate))
                        InfoDisplay(title: language.localized("เวลาเกิด", "Birth Time"), value: user.birthTime)
                        InfoDisplay(title: language.localized("เบอร์โทรศัพท์", "Phone Number"), value: user.phoneNumber)
                        InfoDisplay(title: language.localized("เลขที่บ้าน", "House Number"), value: user.houseNumber)
                        InfoDisplay(title: language.localized("ทะเบียนรถ", "Car Plate"), value: user.carPlate)
                        
                        Divider()
                        SectionTitle(titleTH: "บัญชีผู้ใช้", titleEN: "Account")
                        InfoDisplay(title: "Email", value: user.email)
                        InfoDisplay(title: "Password", value: "••••••")
                        
                        // 🔧 ปุ่มแก้ไขข้อมูล (เหมือนเดิม)
                        NavigationLink(destination: EditProfileView(user: user)) {
                            Text(language.localized("แก้ไขข้อมูล", "Edit Info"))
                                .font(.headline)
                                .foregroundColor(.purple)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple))
                        }
                        .padding(.horizontal)
                    } else {
                        Text(language.localized("ไม่พบข้อมูลผู้ใช้", "User not found"))
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Divider() // เส้นคั่นก่อน Section ใหม่
                    
                    // --- ส่วนตั้งค่า (เหมือนเดิม) ---
                    Section {
                        Button(action: { flowManager.navigateTo(.bookmarks) }) {
                            HStack {
                                Label(language.localized("สถานที่ที่บันทึกไว้", "Bookmarked Places"), systemImage: "bookmark.fill")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary.opacity(0.5))
                            }
                        }
                        Toggle(isOn: $language.isDarkMode) {
                            Label(language.localized("โหมดมืด", "Dark Mode"), systemImage: "moon")
                        }
                        Toggle(isOn: Binding(
                            get: { language.currentLanguage == "en" },
                            set: { _ in language.toggleLanguage() }
                        )) {
                            Label(language.localized("ภาษาอังกฤษ", "English Language"), systemImage: "globe")
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .tint(.purple)
                    
                    
                    // 🔓 Logout (เหมือนเดิม)
                    Spacer(minLength: 24)
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label(language.localized("ออกจากระบบ", "Logout"), systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .padding(.horizontal)
                    .alert(language.localized("ยืนยันการออกจากระบบ", "Confirm Logout"), isPresented: $showLogoutAlert) {
                        Button(language.localized("ยืนยัน", "Confirm"), role: .destructive) {
                            loggedInEmail = "" // ล้าง Email ที่จำไว้
                            flowManager.isLoggedIn = false
                            flowManager.navigateTo(.login)
                        }
                        Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
                    }
                }
                .padding(.bottom)
            } // End ScrollView
            .onAppear {
                loadSavedImage()
                // --- 👇 [แก้ไข] ลบการโหลด userRecords ---
                // userRecords = checkInStore.records(...) // <--- ลบออก
                // --- 👆 สิ้นสุด ---
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in // ใช้ Syntax ใหม่
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.profileImage = uiImage
                        UserDefaults.standard.set(data, forKey: imageKey)
                    }
                }
            }
        } // End else (สำหรับ Login อยู่)
        // --- 👆 สิ้นสุดการเช็ค ---
    } // End body
    
    // ... (Functions: loadSavedImage, formattedDate เหมือนเดิม) ...
    func loadSavedImage() {
        if let data = UserDefaults.standard.data(forKey: imageKey),
           let uiImage = UIImage(data: data) {
            self.profileImage = uiImage
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.calendar = Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian)
        return formatter.string(from: date).replacingOccurrences(of: " BE", with: "")
    }
    
} // End struct

struct GuestLoginPromptView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            Text(language.localized("ดูข้อมูลส่วนตัว", "View Your Profile"))
                .font(.title2.bold())
            Text(language.localized("เข้าสู่ระบบหรือสมัครสมาชิกเพื่อดูและแก้ไขข้อมูลส่วนตัวของคุณ รวมถึงดูประวัติกิจกรรมและแต้มบุญ",
                                    "Log in or register to view and edit your personal information, activity history, and merit points."))
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // --- 👇 [แก้ไข] ปุ่ม - กลับไปใช้ Background/Foreground ---
            Button {
                print("Guest prompt button tapped!")
                flowManager.exitGuestMode() // กลับไปหน้า Login
            } label: {
                Text(language.localized("เข้าสู่ระบบ / สมัครสมาชิก", "Login / Register"))
                    .fontWeight(.bold)
                    .padding() // Padding ภายใน Text
                    .frame(maxWidth: .infinity) // ทำให้ Text เต็มความกว้างก่อนใส่ Background
                    .background(Color.purple) // <--- กำหนด Background Color
                    .foregroundColor(.white) // <--- กำหนด Foreground Color
                    .cornerRadius(12) // <--- กำหนด Corner Radius
            }
            .padding() // Padding รอบปุ่มเหมือนเดิม
            
            Spacer()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct InfoDisplay: View { /* ... */
    let title: String; let value: String
    var body: some View {
        HStack(alignment: .top) {
            Text(title).font(.body).foregroundColor(.purple).frame(width: 110, alignment: .leading)
            Text(value).font(.body).padding(10).frame(maxWidth: .infinity, alignment: .leading).background(Color(.systemGray6)).cornerRadius(8)
        }.padding(.horizontal)
    }
}
struct SectionTitle: View { /* ... */
    var titleTH: String; var titleEN: String
    @EnvironmentObject var language: AppLanguage
    var body: some View {
        HStack { Text(language.localized(titleTH, titleEN)).font(.headline).padding(.leading); Spacer() }
    }
}
