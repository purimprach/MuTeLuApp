import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showLogoutAlert = false
    
    @EnvironmentObject var checkInStore: CheckInStore
    @State private var userRecords: [CheckInRecord] = []
    
    var currentUser: Member? {
        memberStore.members.first { $0.email.lowercased() == loggedInEmail.lowercased() }
    }
    
    var imageKey: String {
        "profileImage_\(loggedInEmail.lowercased())"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 📷 รูปโปรไฟล์
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
                
                // 🧾 ข้อมูลผู้ใช้
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
                    
                    // 🔧 ปุ่มแก้ไขข้อมูล
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
                // ... ในไฟล์ ProfileView.swift ...
                
                Divider() // เส้นคั่นก่อน Section ใหม่
                
                // --- 👇 แทนที่โค้ดเก่าด้วย Section ใหม่นี้ทั้งหมด ---
                Section {
                    // 1. ปุ่ม "สถานที่ที่บันทึกไว้"
                    Button(action: {
                        flowManager.currentScreen = .bookmarks
                    }) {
                        // ทำให้เหมือนแถวใน List และมี > ด้านหลัง
                        HStack {
                            Label(language.localized("สถานที่ที่บันทึกไว้", "Bookmarked Places"), systemImage: "bookmark.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                    
                    // 2. Toggle "โหมดมืด"
                    Toggle(isOn: $language.isDarkMode) {
                        Label(language.localized("โหมดมืด", "Dark Mode"), systemImage: "moon")
                    }
                    
                    // 3. Toggle "ภาษาอังกฤษ"
                    Toggle(isOn: Binding(
                        get: { language.currentLanguage == "en" },
                        set: { _ in language.toggleLanguage() }
                    )) {
                        Label(language.localized("ภาษาอังกฤษ", "English Language"), systemImage: "globe")
                    }
                }
                .foregroundColor(.primary) // ทำให้สีตัวหนังสือเป็นสีปกติ
                .padding(.horizontal)
                .tint(.purple) // ทำให้สีของ Toggle และไอคอนเป็นสีม่วงสวยงาม
                
                
                // 🔓 Logout
                Spacer(minLength: 24)
                Button(role: .destructive) { // 👈 เพิ่ม role เป็น .destructive
                    showLogoutAlert = true
                } label: {
                    Label(language.localized("ออกจากระบบ", "Logout"), systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent) // 👈 ใช้ Style ที่ระบบเตรียมไว้ให้
                .tint(.red) // 👈 กำหนดให้เป็นสีแดง ซึ่งสื่อถึงการกระทำที่มีความเสี่ยง
                .padding(.horizontal)
                .alert(language.localized("ยืนยันการออกจากระบบ", "Confirm Logout"), isPresented: $showLogoutAlert) {
                    Button(language.localized("ยืนยัน", "Confirm"), role: .destructive) {
                        flowManager.isLoggedIn = false
                        flowManager.currentScreen = .login
                    }
                    Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
                }
            }
            .padding(.bottom)
        }
        .onAppear {
            loadSavedImage()
            userRecords = checkInStore.records(for: loggedInEmail).sorted { $0.date > $1.date }
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    self.profileImage = uiImage
                    UserDefaults.standard.set(data, forKey: imageKey)
                }
            }
        }
    }
    
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
}
// MARK: - Subcomponents
struct InfoDisplay: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.body)
                .foregroundColor(.purple)
                .frame(width: 110, alignment: .leading)
            
            Text(value)
                .font(.body)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct SectionTitle: View {
    var titleTH: String
    var titleEN: String
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        HStack {
            Text(language.localized(titleTH, titleEN))
                .font(.headline)
                .padding(.leading)
            Spacer()
        }
    }
}
