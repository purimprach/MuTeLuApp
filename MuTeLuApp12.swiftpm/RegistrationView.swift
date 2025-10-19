import SwiftUI
import CryptoKit

struct RegistrationView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @State private var showConfirmAlert = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // State properties (เหมือนเดิม)
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var gender = "ชาย"
    @State private var birthdate = Date()
    @State private var birthTime = ""
    @State private var phoneNumber = ""
    @State private var houseNumber = ""
    @State private var carPlate = ""
    
    // @State private var activeAlert: AppAlert? // Keep if used elsewhere
    
    let genderOptions = ["ชาย", "หญิง", "อื่นๆ"]
    
    // MARK: - Body (UI ตามที่คุณให้มา)
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header (เหมือนเดิม)
                Text(language.localized("ลงทะเบียน", "Register"))
                    .font(.largeTitle.bold())
                    .foregroundColor(AppColor.textPrimary.color)
                    .padding(.top)
                
                // Required Fields (เหมือนเดิม)
                RequiredField(title: language.localized("อีเมล", "Email"), text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                RequiredPasswordField(title: language.localized("รหัสผ่าน", "Password"), text: $password)
                RequiredPasswordField(title: language.localized("ยืนยันรหัสผ่าน", "Confirm Password"), text: $confirmPassword)
                
                Divider().padding(.vertical)
                
                // Optional Fields Title (เหมือนเดิม)
                Text(language.localized("ข้อมูลเพิ่มเติม (ไม่จำเป็น)", "Optional Information"))
                    .font(.headline)
                    .foregroundColor(AppColor.textSecondary.color)
                    .padding(.top, 5)
                
                // Optional Fields (เหมือนเดิม)
                InputField(title: language.localized("ชื่อ-สกุล", "Full Name"), text: $fullName)
                genderPicker
                DatePicker(language.localized("วันเดือนปีเกิด", "Birthdate"), selection: $birthdate, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US"))
                    .environment(\.calendar, Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian))
                    .tint(AppColor.brandPrimary.color)
                    .padding(.horizontal)
                InputField(title: language.localized("เวลาเกิด", "Birth Time"), text: $birthTime)
                InputField(title: language.localized("เบอร์โทรศัพท์", "Phone Number"), text: $phoneNumber)
                    .keyboardType(.phonePad)
                InputField(title: language.localized("เลขที่บ้าน", "House Number"), text: $houseNumber)
                InputField(title: language.localized("ทะเบียนรถ", "Car Plate"), text: $carPlate)
                
                // Confirm Button (เหมือนเดิม)
                Button(action: {
                    showConfirmAlert = true
                }) {
                    Text(language.localized("ยืนยันการลงทะเบียน", "Confirm Registration"))
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.brandPrimary.color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .confirmationDialog(
                    language.localized("ยืนยันการลงทะเบียน", "Confirm Registration"),
                    isPresented: $showConfirmAlert,
                    titleVisibility: .visible
                ) {
                    Button(language.localized("ยืนยัน", "Confirm")) {
                        handleRegister() // เรียก handleRegister เมื่อกดยืนยัน
                    }
                    Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) { }
                }
                
                // Back to Login Button
                Button(action: {
                    // --- 👇 จุดแก้ไขที่ 2 ---
                    flowManager.navigateTo(.login) // ใช้ navigateTo
                    // --- 👆 สิ้นสุดส่วนแก้ไข ---
                }) {
                    Text(language.localized("กลับไปหน้าเข้าสู่ระบบ", "Back to Login"))
                        .font(.footnote)
                        .foregroundColor(AppColor.brandPrimary.color)
                        .underline()
                }
            }
            .padding()
        }
        .background(AppColor.backgroundPrimary.color.ignoresSafeArea()) // Apply background and ignore safe area
        .alert(isPresented: $showAlert) { // Error Alert (เหมือนเดิม)
            Alert(title: Text(language.localized("ข้อผิดพลาด", "Error")),
                  message: Text(alertMessage),
                  dismissButton: .default(Text(language.localized("ตกลง", "OK"))))
        }
    }
    
    // MARK: - Subviews (เหมือนเดิม)
    
    var genderPicker: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(language.localized("เพศ", "Gender")).font(.caption).foregroundColor(.gray)
            Picker("", selection: $gender) {
                ForEach(genderOptions, id: \.self) { option in
                    Text(localizedGender(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .tint(AppColor.brandPrimary.color) // Apply tint
        }
        .padding(.horizontal)
    }
    
    private func localizedGender(_ key: String) -> String {
        switch key {
        case "ชาย": return language.localized("ชาย", "Male")
        case "หญิง": return language.localized("หญิง", "Female")
        case "อื่นๆ": return language.localized("อื่นๆ", "Other")
        default: return key
        }
    }
    
    // MARK: - Action Functions
    
    func handleRegister() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation (เหมือนเดิม)
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty, !trimmedConfirmPassword.isEmpty else {
            alertMessage = language.localized("กรุณากรอกข้อมูลที่จำเป็น (*) ให้ครบถ้วน", "Please fill in all required (*) fields")
            showAlert = true
            return
        }
        guard isValidEmail(trimmedEmail) else {
            alertMessage = language.localized("รูปแบบอีเมลไม่ถูกต้อง", "Invalid email format")
            showAlert = true
            return
        }
        guard trimmedPassword == trimmedConfirmPassword else {
            alertMessage = language.localized("รหัสผ่านและการยืนยันรหัสผ่านไม่ตรงกัน", "Passwords do not match")
            showAlert = true
            return
        }
        // --- 👇 เพิ่มการตรวจสอบความยาวและรูปแบบรหัสผ่าน ---
        guard isPasswordValid(trimmedPassword) else {
            alertMessage = language.localized(
                "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร ประกอบด้วยตัวพิมพ์ใหญ่ ตัวพิมพ์เล็ก ตัวเลข และอักขระพิเศษ",
                "Password must be at least 8 characters long and include uppercase, lowercase, number, and special character."
            )
            showAlert = true
            return
        }
        // --- 👆 สิ้นสุดการตรวจสอบรหัสผ่าน ---
        if memberStore.members.contains(where: { $0.email.lowercased() == trimmedEmail }) {
            alertMessage = language.localized("อีเมลนี้ถูกใช้ลงทะเบียนแล้ว", "This email is already registered")
            showAlert = true
            return
        }
        
        // Create new member (เหมือนเดิม)
        let newMember = Member(
            email: trimmedEmail,
            password: hashPassword(trimmedPassword),
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            gender: gender,
            birthdate: birthdate,
            birthTime: birthTime.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            houseNumber: houseNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            carPlate: carPlate.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // Add member to store (เหมือนเดิม)
        memberStore.addMember(newMember) // Assuming addMember handles saving
        // 1. ตั้งค่า Email ที่ login อยู่ปัจจุบัน
        loggedInEmail = newMember.email
        
        // 2. ตั้งค่าสถานะ Login ใน FlowManager
        flowManager.isLoggedIn = true
        
        // 3. ไปยังหน้า Home แทนหน้า Login
        flowManager.navigateTo(.home) // Use navigateTo
        
    }
    
    // Email Validation Helper (เหมือนเดิม)
    func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    // --- 👇 ฟังก์ชันตรวจสอบรหัสผ่านใหม่ ---
    func isPasswordValid(_ password: String) -> Bool {
        // 1. ความยาวอย่างน้อย 8 ตัว
        if password.count < 8 { return false }
        
        // 2. มีตัวพิมพ์เล็กอย่างน้อย 1 ตัว
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
        if !lowercasePredicate.evaluate(with: password) { return false }
        
        // 3. มีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        if !uppercasePredicate.evaluate(with: password) { return false }
        
        // 4. มีตัวเลขอย่างน้อย 1 ตัว
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
        if !numberPredicate.evaluate(with: password) { return false }
        
        // 5. มีอักขระพิเศษอย่างน้อย 1 ตัว (ตัวอย่าง: !@#$%^&*()-_=+[{]};:'",.<>/?`~)
        // คุณสามารถปรับแก้ชุดอักขระพิเศษได้ตามต้องการ
        let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[!@#$%^&*()\\-_=+\\[{\\]};:'\",.<>/?`~]+.*")
        if !specialCharacterPredicate.evaluate(with: password) { return false }
        
        // ผ่านทุกเงื่อนไข
        return true
    }
    // --- 👆 สิ้นสุดฟังก์ชันตรวจสอบรหัสผ่าน ---
    
    // Password Hashing Helper (เหมือนเดิม)
    private func hashPassword(_ password: String) -> String {
        guard let data = password.data(using: .utf8) else { return "" }
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
} // <-- End of RegistrationView

// MARK: - Reusable Input Field Components (เหมือนเดิม)
// ... (โค้ด InputField, RequiredField, RequiredPasswordField อยู่ตรงนี้) ...
// InputField (Normal)
struct InputField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppColor.textSecondary.color)
                .frame(width: 110, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle for better background control
                .padding(10) // Padding inside the field
                .background(AppColor.backgroundSecondary.color) // Background color for the field
                .cornerRadius(8)
                .tint(AppColor.brandPrimary.color) // Cursor/highlight color
        }
        .padding(.horizontal) // Padding outside the HStack
    }
}

// RequiredField (With asterisk)
struct RequiredField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColor.textSecondary.color)
                Text("*")
                    .foregroundColor(.red)
            }
            .frame(width: 110, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(AppColor.backgroundSecondary.color)
                .cornerRadius(8)
                .tint(AppColor.brandPrimary.color)
        }
        .padding(.horizontal)
    }
}

// RequiredPasswordField (With show/hide button)
struct RequiredPasswordField: View {
    var title: String
    @Binding var text: String
    @State private var showPassword: Bool = false // Local state for visibility
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColor.textSecondary.color)
                Text("*")
                    .foregroundColor(.red)
            }
            .frame(width: 110, alignment: .leading)
            
            HStack { // HStack for the field and the button
                Group { // Group to switch between SecureField and TextField
                    if showPassword {
                        TextField(title, text: $text)
                    } else {
                        SecureField(title, text: $text)
                    }
                }
                .autocapitalization(.none) // Common modifiers
                .disableAutocorrection(true)
                .textContentType(.oneTimeCode) // Prevent strong password suggestions if not desired
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(AppColor.textSecondary.color) // Use secondary text color for icon
                }
                .buttonStyle(.plain) // Ensure button doesn't have default styling
            }
            .textFieldStyle(PlainTextFieldStyle()) // Apply style to the inner HStack content
            .padding(10)
            .background(AppColor.backgroundSecondary.color)
            .cornerRadius(8)
            .tint(AppColor.brandPrimary.color)
        }
        .padding(.horizontal)
    }
}


// AppAlert Struct (เหมือนเดิม)
struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let confirmAction: (() -> Void)? = nil
}

// Preview Provider (เหมือนเดิม)
#Preview {
    // NavigationView { // Use if needed
    RegistrationView()
        .environmentObject(AppLanguage())
        .environmentObject(MuTeLuFlowManager())
        .environmentObject(MemberStore())
    // }
}
