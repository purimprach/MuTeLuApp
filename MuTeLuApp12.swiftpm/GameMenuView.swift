import SwiftUI

struct GameMenuView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        ZStack {
            // MARK: - 1. เพิ่มพื้นหลัง
            LinearGradient(
                colors: [Color.gray.opacity(0.5), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: - 2. Header
                HStack {
                    BackButton()
                    Spacer()
                }
                
                Text(language.localized("เกมส่งเสริมวัฒนธรรม", "Cultural Games"))
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.black.gradient)
                
                // MARK: - 3. รายการเมนูเกม
                VStack(spacing: 16) {
                    GameCard(
                        title: language.localized("จัดของใส่บาตร", "Offering Game"),
                        icon: "gift.fill",
                        screen: .offeringGame
                    )
                    
                    // --- เกมใหม่ (Coming Soon) ---
                    GameCard(
                        title: language.localized("คำถามทดสอบศีล 5", "The Five Precepts Quiz"),
                        icon: "questionmark.diamond.fill",
                        screen: .gameQuiz
                    )
                    
                    GameCard(
                        title: language.localized("ฝึกสมาธิ กำหนดลมหายใจ", "Breathing Meditation"),
                        icon: "wind",
                        screen: .gameMeditation
                    )
                    
                    GameCard(
                        title: language.localized("จับคู่สัญลักษณ์มงคล", "Lucky Symbols Match"),
                        icon: "squares.below.rectangle",
                        screen: .gameMatching
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
}


// VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
// MARK: - [แก้ไข] Component สำหรับปุ่มเมนูเกม (ใช้เวอร์ชันนี้)
struct GameCard: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager // 👈 ต้องมี flowManager ที่นี่
    let title: String
    let icon: String
    let screen: MuTeLuScreen
    
    var body: some View {
        Button(action: {
            flowManager.currentScreen = screen // 👈 action จะถูกจัดการในนี้
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(Color.blue.gradient)
                    .frame(width: 50)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(1))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        }
    }
}
