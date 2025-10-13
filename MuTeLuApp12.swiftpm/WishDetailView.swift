import SwiftUI

struct WishDetailView: View {
    @EnvironmentObject var flow: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        ZStack {
            // MARK: - 1. เพิ่มพื้นหลังไล่ระดับสี
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // เพิ่ม spacing ระหว่างการ์ด
                    
                    // MARK: - Back Button (ย้ายมาไว้ใน VStack)
                    Button(action: {
                        flow.currentScreen = .knowledge // กลับไปหน้า Knowledge Menu
                    }) {
                        Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    .padding(.bottom)
                    
                    // MARK: - การ์ด: ประเภทของสิ่งศักดิ์สิทธิ์
                    InfoCard(
                        title: language.localized("ประเภทของสิ่งศักดิ์สิทธิ์", "Types of Sacred Beings"),
                        icon: "person.3.fill"
                    ) {
                        Text(language.localized("การไหว้ขอพรสิ่งศักดิ์สิทธิ์ที่เราศรัทธานั้น อาจแบ่งออกได้เป็น 3 กลุ่มหลัก ได้แก่:", "Praying to sacred beings we revere can be categorized into three main groups:"))
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• " + language.localized("สายพุทธ (พระพุทธเจ้า พระอรหันต์)", "Buddhist Lineage (Buddha, Arahants)"))
                            Text("• " + language.localized("สายฮินดู (พระพรหม พระพิฆเนศ พระศิวะ ฯลฯ)", "Hindu Lineage (Brahma, Ganesha, Shiva, etc.)"))
                            Text("• " + language.localized("สายบุคคล (ครูบาอาจารย์ บรรพบุรุษ)", "Respected Individuals (Masters, Ancestors)"))
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                    }
                    
                    // MARK: - การ์ด: วิธีการขอพร
                    InfoCard(
                        title: language.localized("วิธีการขอพร", "How to Make a Wish"),
                        icon: "hands.sparkles.fill"
                    ) {
                        Text(language.localized("หลังจากกล่าวคำนอบน้อม หรือถวายเครื่องสักการะแล้ว สามารถกล่าวขอพรต่อหน้าสิ่งศักดิ์สิทธิ์ด้วยคำพูดของตนเอง โดยอาจใช้โครงสร้างดังนี้:", "After paying respects or making offerings, you can state your wish in your own words using this structure:"))
                            .font(.body)
                        
                        // กรอบข้อความคำอธิษฐาน
                        VStack(alignment: .leading, spacing: 10) {
                            Text(language.localized("ข้าพเจ้า [ชื่อ-นามสกุล] ขอกราบขอพรเพื่อบารมีของ [ชื่อสิ่งศักดิ์สิทธิ์] โปรดดลบันดาลให้ข้าพเจ้าประสบความสำเร็จในเรื่อง [สิ่งที่ปรารถนา]", "I, [Full Name], humbly ask for the blessings of [Name of Deity] to grant me success in [Your Wish]."))
                            
                            Text(language.localized("“เมื่อความปรารถนาสำเร็จ ข้าพเจ้าจะ [ของที่ใช้แก้บน] มาถวายเป็นการแก้บนตามคำสัจจะ”", "\"When this wish is fulfilled, I will offer [Votive Offering] to honor my vow.\""))
                        }
                        .font(.system(.callout, design: .rounded).weight(.medium))
                        .italic()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow.opacity(0.15))
                        .cornerRadius(12)
                    }
                    
                    // MARK: - การ์ด: หลักสำคัญ
                    InfoCard(
                        title: language.localized("หลักสำคัญให้พรสำเร็จ", "Keys to a Successful Wish"),
                        icon: "key.fill"
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. " + language.localized("จิตใจแน่วแน่: ขณะขอพร ควรมีสมาธิ ใจนิ่ง และมุ่งมั่น", "Focused Mind: Be concentrated, calm, and determined while wishing."))
                            Text("2. " + language.localized("เชื่อมั่นศรัทธา: ความเชื่อคือหัวใจสำคัญ", "Strong Faith: Belief is the essential key."))
                            Text("3. " + language.localized("ประพฤติดีสม่ำเสมอ: สิ่งศักดิ์สิทธิ์จะช่วยผู้ที่เหมาะสม", "Consistent Good Deeds: Sacred beings assist those who are worthy."))
                        }
                        .font(.body)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(language.localized("หลักการขอพร", "Principles of Wishing"))
        .navigationBarHidden(true) // ซ่อน Navigation Bar เพราะเรามีปุ่ม Back เอง
    }
}


// MARK: - Reusable InfoCard Component
// สร้าง View Component สำหรับการ์ดข้อมูลเพื่อนำไปใช้ซ้ำ
struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.title3.bold())
                .foregroundStyle(Color.purple.gradient)
            
            Divider()
            
            content
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}
