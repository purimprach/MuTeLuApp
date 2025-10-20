import SwiftUI
import CryptoKit

struct LoginView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var memberStore: MemberStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    @AppStorage("currentUserEmail") var currentUserEmail = ""
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var showGreetingPopup = false
    @State private var greetingName = ""
    @State private var randomGreetingMessage = ""
    
    // MARK: Greetings
    let greetingsTH = [
        "ขอให้วันนี้เต็มไปด้วยพลังบวก ความสุข และความสำเร็จในทุก ๆ ด้านของชีวิต",
        "ขอให้คุณพบเจอแต่สิ่งดี ๆ ทั้งโอกาสใหม่ ๆ และผู้คนที่นำพาพลังงานดีเข้ามา",
        "วันนี้จะเป็นวันที่ยอดเยี่ยม เต็มไปด้วยรอยยิ้มและความก้าวหน้า",
        "ขอให้สิ่งที่คุณตั้งใจและทุ่มเทประสบผลสำเร็จสมความตั้งใจ",
        "วันนี้คุณจะโชคดีเกินคาด สิ่งที่รอคอยอาจมาถึงเร็วกว่าที่คิด",
        "ทุกย่างก้าวในวันนี้ขอให้เต็มไปด้วยแรงบันดาลใจและความสุข",
        "เริ่มต้นวันใหม่ด้วยหัวใจที่เข้มแข็ง แล้วสิ่งดี ๆ จะเข้ามาหาคุณอย่างต่อเนื่อง"
    ]
    let greetingsEN = [
        "May your day be filled with positivity, happiness, and success in every aspect of life.",
        "Wishing you wonderful opportunities and inspiring people who bring good energy into your world.",
        "Today will be an amazing day, filled with smiles, growth, and achievements.",
        "May everything you’ve worked hard for bring you the success you truly deserve.",
        "Unexpected luck and pleasant surprises await you today—get ready for something wonderful.",
        "May every step you take today be guided by inspiration, joy, and confidence.",
        "Start this day with strength in your heart, and the universe will respond with endless blessings."
    ]
    private var greetingsLocalized: [String] {
        language.currentLanguage == "th" ? greetingsTH : greetingsEN
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7),
                                            Color(red: 0.1, green: 0, blue: 0.3)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Language Picker
                HStack {
                    Spacer()
                    Picker("", selection: $language.currentLanguage) {
                        Text("TH").tag("th")
                        Text("EN").tag("en")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
                .padding(.top)
                .padding(.trailing)
                
                Spacer()
                
                // Logo and Title
                Image("LogoMuTeLu")
                    .resizable().scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                
                Text("Mu Te Lu")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                
                Text(language.localized("แอปสายมูสำหรับคุณ", "A spiritual guide for you"))
                    .font(.headline).foregroundColor(.white.opacity(0.85))
                
                // Email Input
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField(language.localized("อีเมล", "Email"), text: $username)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal)
                
                // Password Input
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField(language.localized("รหัสผ่าน", "Password"), text: $password)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal)
                
                // Login Button
                Button(action: handleLogin) {
                    Label(language.localized("เข้าสู่ระบบ", "Login"), systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty ||
                          password.trimmingCharacters(in: .whitespaces).isEmpty)
                
                // Register Button
                Button {
                    flowManager.navigateTo(.registration)
                } label: {
                    Text(language.localized("ยังไม่ได้เป็นสมาชิก กดที่นี่", "Not a member yet? Tap here."))
                        .font(.footnote)
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.bottom, 10) // เพิ่มระยะห่างด้านล่างปุ่ม Register
                
                // --- 👇 [แก้ไข] จัดกลุ่มปุ่ม Admin และ Guest ---
                HStack(spacing: 20) {
                    // Admin Login Button
                    Button(language.localized("< ระบบผู้ดูแล >", "< Admin > Login")) {
                        flowManager.navigateTo(.adminLogin)
                    }
                    .font(.footnote) // ใช้ .footnote อาจจะดูขนาดเหมาะสมกว่า .caption
                    .foregroundColor(.white.opacity(0.7))
                    
                    // ตัวคั่น
                    Text("|")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.5))
                    
                    // Guest Mode Button
                    Button {
                        flowManager.enterGuestMode()
                    } label: {
                        Text(language.localized("เข้าใช้งานทั่วไป", "Continue as Guest"))
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                }
                // --- 👆 สิ้นสุดการแก้ไข ---
                
                Spacer()
            }
            .blur(radius: showGreetingPopup ? 3 : 0)
            
            // Greeting Popup
            if showGreetingPopup {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showGreetingPopup = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flowManager.isLoggedIn = true
                                flowManager.navigateTo(.home)
                            }
                        }
                    
                    VStack(spacing: 16) {
                        Text("🎉").font(.system(size: 50))
                        Text(language.localized("สวัสดีครับคุณ\n\(greetingName)", "Hello, \(greetingName)"))
                            .font(.title2).fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(randomGreetingMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            withAnimation { showGreetingPopup = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flowManager.isLoggedIn = true
                                flowManager.navigateTo(.home)
                            }
                        }) {
                            Text(language.localized("ตกลง", "OK"))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(EdgeInsets(top: 30, leading: 20, bottom: 20, trailing: 20))
                    .frame(minWidth: 280, maxWidth: 400)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
                }
            }
        }
        .animation(.spring(), value: showGreetingPopup)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text(language.localized("เกิดข้อผิดพลาด", "Error")),
                message: Text(errorMessage),
                dismissButton: .default(Text(language.localized("ตกลง", "OK")))
            )
        }
        .onAppear {
            if !currentUserEmail.isEmpty && username.isEmpty {
                username = currentUserEmail
            }
        }
    }
    
    // MARK: - Actions
    func handleLogin() {
        let trimmedEmail = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let index = memberStore.members.firstIndex(where: { $0.email.lowercased() == trimmedEmail }) {
            let matched = memberStore.members[index]
            
            if matched.password == hashPassword(trimmedPassword) {
                memberStore.recordLogin(email: matched.email)
                currentUserEmail = matched.email
                loggedInEmail = matched.email
                greetingName = matched.fullName
                randomGreetingMessage = greetingsLocalized.randomElement() ?? ""
                withAnimation { showGreetingPopup = true }
                // เอา navigateTo(.home) ออก
            } else {
                errorMessage = language.localized("อีเมลหรือรหัสผ่านไม่ถูกต้อง", "Incorrect email or password")
                showErrorAlert = true
            }
        } else {
            errorMessage = language.localized("อีเมลหรือรหัสผ่านไม่ถูกต้อง", "Incorrect email or password")
            showErrorAlert = true
        }
    }
    
    // MARK: - Hash
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
