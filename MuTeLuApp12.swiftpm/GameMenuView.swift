import SwiftUI

struct GameMenuView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // รับ flowManager
    
    var body: some View {
        ZStack {
            // MARK: - 1. เพิ่มพื้นหลัง (โค้ดเดิมของคุณ)
            LinearGradient(
                colors: [Color.gray.opacity(0.5), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: - 2. Header (โค้ดเดิมของคุณ)
                HStack {
                    BackButton()
                        .environmentObject(flowManager) // ส่ง flowManager ให้ BackButton
                        .environmentObject(language) // ส่ง language ให้ BackButton
                    Spacer()
                }
                
                Text(language.localized("เกมส่งเสริมวัฒนธรรม", "Cultural Games"))
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.black.gradient) // ใช้ .primary.gradient จะดีกว่าสำหรับ Dark Mode
                
                // MARK: - 3. รายการเมนูเกม (โค้ดเดิมของคุณ)
                VStack(spacing: 16) {
                    GameCard(
                        title: language.localized("จัดของใส่บาตร", "Offering Game"),
                        icon: "gift.fill",
                        screen: .offeringGame
                    )
                    // ส่ง flowManager และ language ให้ GameCard
                    .environmentObject(flowManager)
                    .environmentObject(language) // ถ้า GameCard มีการใช้ภาษา
                    
                    // --- เกมใหม่ (Coming Soon) ---
                    GameCard(
                        title: language.localized("คำถามทดสอบศีล 5", "The Five Precepts Quiz"),
                        icon: "questionmark.diamond.fill",
                        screen: .gameQuiz // หน้าจอสำหรับเกมนี้
                    )
                    .environmentObject(flowManager)
                    .environmentObject(language)
                    
                    GameCard(
                        title: language.localized("ฝึกสมาธิ กำหนดลมหายใจ", "Breathing Meditation"),
                        icon: "wind",
                        screen: .gameMeditation // หน้าจอสำหรับเกมนี้
                    )
                    .environmentObject(flowManager)
                    .environmentObject(language)
                    
                    GameCard(
                        title: language.localized("จับคู่สัญลักษณ์มงคล", "Lucky Symbols Match"),
                        icon: "squares.below.rectangle",
                        screen: .gameMatching // หน้าจอสำหรับเกมนี้
                    )
                    .environmentObject(flowManager)
                    .environmentObject(language)
                }
                
                Spacer()
            }
            .padding()
        }
        // ไม่ต้องมี navigationTitle ที่นี่ ถ้าไม่ได้อยู่ใน NavigationView/NavigationStack
    }
}


// VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
// MARK: - [แก้ไข] Component สำหรับปุ่มเมนูเกม (ใช้เวอร์ชันนี้)
struct GameCard: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager // 👈 รับ flowManager
    @EnvironmentObject var language: AppLanguage // 👈 รับ language (เผื่อใช้ในอนาคต)
    let title: String
    let icon: String
    let screen: MuTeLuScreen
    
    var body: some View {
        Button(action: {
            // --- 👇 แก้ไขตรงนี้ ---
            flowManager.navigateTo(screen) // 👈 ใช้ navigateTo แทน
            // --- 👆 สิ้นสุดส่วนแก้ไข ---
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title) // ขนาด icon ตามโค้ดเดิม
                    .foregroundStyle(Color.blue.gradient) // สี icon ตามโค้ดเดิม
                    .frame(width: 50) // ขนาด frame ตามโค้ดเดิม
                
                Text(title) // ใช้ title ที่รับเข้ามาโดยตรง (มีการ localize จากข้างนอกแล้ว)
                    .font(.headline)
                    .foregroundColor(.primary) // ใช้ primary color
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(1)) // สี chevron ตามโค้ดเดิม
            }
            .padding()
            .background(.ultraThinMaterial) // background ตามโค้ดเดิม
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // corner radius ตามโค้ดเดิม
            .shadow(color: .black.opacity(0.05), radius: 5, y: 3) // shadow ตามโค้ดเดิม
        }
        .buttonStyle(.plain) // ทำให้กดได้ทั้งแถวและไม่มี effect แปลกๆ
    }
}
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

// Preview (ถ้ามี ควรใส่ EnvironmentObjects)
#Preview {
    GameMenuView()
        .environmentObject(AppLanguage())
        .environmentObject(MuTeLuFlowManager())
}
