import SwiftUI

struct GreetingStartupView: View {
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    var currentMember: Member? {
        // ใช้ .lowercased() เพื่อป้องกันปัญหา Case Sensitive ตอนเทียบ email
        memberStore.members.first { $0.email.lowercased() == loggedInEmail.lowercased() }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Spacer() // เพิ่ม Spacer ด้านบนเพื่อให้ข้อความอยู่กลางๆ
            
            if let member = currentMember {
                // ใช้ Text Interpolation ดีกว่าต่อ String
                Text(language.localized("สวัสดีครับคุณ \(member.fullName)", "Hello, \(member.fullName)"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center) // เผื่อชื่อยาว
                
                Text(language.localized("อย่าลืมเช็กดวงประจำวันนะครับ", "Don't forget to check your daily fortune!"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                // กรณีไม่พบ member (อาจเกิดขึ้นได้)
                Text(language.localized("ยินดีต้อนรับสู่ Mu Te Lu", "Welcome to Mu Te Lu"))
                    .font(.title2)
                    .fontWeight(.bold)
                Text(language.localized("กำลังโหลดข้อมูล...", "Loading data..."))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Spacer() // เพิ่ม Spacer ด้านล่าง
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ทำให้ VStack ขยายเต็มพื้นที่
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // เพิ่มพื้นหลัง
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // --- 👇 แก้ไขตรงนี้ ---
                flowManager.navigateTo(.home) // ใช้ navigateTo
                // --- 👆 สิ้นสุดส่วนแก้ไข ---
            }
        }
    }
}

// Preview (ถ้ามี) ควรส่ง EnvironmentObject ที่จำเป็นไปด้วย
#Preview {
    GreetingStartupView()
        .environmentObject(MemberStore()) // ตัวอย่าง
        .environmentObject(AppLanguage())
        .environmentObject(MuTeLuFlowManager())
}
