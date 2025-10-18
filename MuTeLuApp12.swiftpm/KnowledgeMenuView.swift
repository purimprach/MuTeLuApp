import SwiftUI

struct KnowledgeMenuView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flow: MuTeLuFlowManager // ชื่อ flowManager ใน EnvironmentObject คือ flow
    
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
                    BackButton() // ปุ่ม BackButton ที่แก้ไขแล้ว
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
                    // ส่ง EnvironmentObject ที่จำเป็นให้ KnowledgeButton
                    .environmentObject(flow)
                    
                    KnowledgeButton(
                        title: language.localized("การจัดของถวายสังฆทาน", "Preparing Offerings"),
                        icon: "gift.fill", // 🎁 ไอคอน
                        screen: .knowledgeOfferings // หน้าจอใหม่
                    )
                    .environmentObject(flow)
                    
                    KnowledgeButton(
                        title: language.localized("ความหมายของตัวเลขมงคล", "Meaning of Lucky Numbers"),
                        icon: "number.circle.fill", // 🔢 ไอคอน
                        screen: .knowledgeNumbers // หน้าจอใหม่
                    )
                    .environmentObject(flow)
                    
                    KnowledgeButton(
                        title: language.localized("การทำ ทาน ศีล ภาวนา", "Giving, Morality & Meditation"),
                        icon: "heart.text.square.fill", // 🙏 ไอคอน
                        screen: .knowledgeBuddhistPrinciples // หน้าจอใหม่
                    )
                    .environmentObject(flow)
                }
                
                Spacer()
            }
            .padding()
        }
        // ไม่จำเป็นต้องมี .navigationTitle ที่นี่ ถ้าหน้านี้ไม่ได้อยู่ใน NavigationStack หลัก
    }
}

// MARK: - Component สำหรับปุ่มเมนู (แก้ไข action)
struct KnowledgeButton: View {
    @EnvironmentObject var flow: MuTeLuFlowManager // รับ flowManager มาใช้
    let title: String
    let icon: String
    let screen: MuTeLuScreen
    
    var body: some View {
        Button(action: {
            // --- 👇 แก้ไขตรงนี้ ---
            flow.navigateTo(screen) // ใช้ navigateTo แทนการกำหนด currentScreen โดยตรง
            // --- 👆 สิ้นสุดส่วนแก้ไข ---
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.purple.gradient)
                    .frame(width: 40)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary) // ใช้ .primary เพื่อรองรับ Dark Mode
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding()
            .background(.ultraThinMaterial) // ใช้ Material เพื่อความสวยงาม
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        }
    }
}

// MARK: - View สำหรับหน้าที่ยังไม่พร้อมใช้งาน (เหมือนเดิม)
struct ComingSoonView: View {
    @EnvironmentObject var language: AppLanguage
    // อาจจะต้องมี @EnvironmentObject var flow: MuTeLuFlowManager ถ้า BackButton ต้องการ
    
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
                    BackButton() // ตรวจสอบว่า BackButton ได้รับ flowManager หรือไม่
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

// Preview (ถ้ามี)
#Preview {
    KnowledgeMenuView()
        .environmentObject(AppLanguage())
        .environmentObject(MuTeLuFlowManager())
}
