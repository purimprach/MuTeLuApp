import SwiftUI

struct KnowledgeMenuView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flow: MuTeLuFlowManager
    
    var body: some View {
        ZStack {
            // MARK: - 1. เพิ่มพื้นหลังไล่ระดับสี
            LinearGradient(
                colors: [Color.purple.opacity(0.15), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: - 2. Header ที่สวยงามขึ้น
                HStack {
                    BackButton()
                    Spacer()
                }
                
                Text(language.localized("เกร็ดความรู้สายมู", "Spiritual Knowledge"))
                    .font(.title).bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.purple.gradient)
                
                // MARK: - 3. รายการเมนูแบบการ์ด
                VStack(spacing: 16) {
                    KnowledgeButton(
                        title: language.localized("หลักการขอพร", "Principles of Wishing"),
                        icon: "hands.sparkles.fill", // ✨ ไอคอน
                        screen: .wishDetail
                    )
                    
                    KnowledgeButton(
                        title: language.localized("การจัดของถวายสังฆทาน", "Preparing Offerings"),
                        icon: "gift.fill", // 🎁 ไอคอน
                        screen: .knowledgeOfferings
                    )
                    
                    KnowledgeButton(
                        title: language.localized("ความหมายของตัวเลขมงคล", "Meaning of Lucky Numbers"),
                        icon: "number.circle.fill", // 🔢 ไอคอน
                        screen: .knowledgeNumbers
                    )
                    
                    KnowledgeButton(
                        title: language.localized("การทำ ทาน ศีล ภาวนา", "Giving, Morality & Meditation"),
                        icon: "heart.text.square.fill", // 🙏 ไอคอน
                        screen: .knowledgeBuddhistPrinciples
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Component สำหรับปุ่มเมนู
struct KnowledgeButton: View {
    @EnvironmentObject var flow: MuTeLuFlowManager
    let title: String
    let icon: String
    let screen: MuTeLuScreen
    
    var body: some View {
        Button(action: {
            flow.currentScreen = screen
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.purple.gradient)
                    .frame(width: 40)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        }
    }
}

// MARK: - View สำหรับหน้าที่ยังไม่พร้อมใช้งาน
struct ComingSoonView: View {
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.15), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    BackButton()
                    Spacer()
                }
                Spacer()
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.purple.gradient)
                Text(language.localized("เนื้อหาจะพร้อมใช้งานเร็วๆ นี้", "Content Coming Soon!"))
                    .font(.title2.bold())
                Text(language.localized("โปรดติดตามการอัปเดตในเวอร์ชันถัดไป", "Please stay tuned for future updates."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}
