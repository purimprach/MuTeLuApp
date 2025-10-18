import SwiftUI

struct CategorySearchView: View {
    @StateObject private var viewModel = SacredPlaceViewModel()
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    // ดึงรายชื่อหมวดหมู่ (Tags) ทั้งหมดที่ไม่ซ้ำกัน
    private var allTags: [String] {
        let allTags = viewModel.places.flatMap { $0.tags }
        // ใช้ Set เพื่อเอาค่าซ้ำออก แล้วแปลงกลับเป็น Array และเรียงลำดับ
        return Array(Set(allTags)).sorted()
    }
    
    var body: some View {
        List {
            // --- Section ที่ 1: สำหรับเมนูพิเศษ ---
            Section {
                NavigationLink(destination: BookmarkView()) {
                    HStack(spacing: 15) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.blue) // เปลี่ยนเป็นสีฟ้าเพื่อให้แตกต่าง
                            .font(.system(size: 20))
                            .frame(width: 25, alignment: .center)
                        
                        Text(language.localized("สถานที่บันทึกไว้", "Bookmarked Places"))
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // --- Section ที่ 2: สำหรับหมวดหมู่ (Tags) ---
            Section(header: Text(language.localized("หมวดหมู่ทั้งหมด", "All Categories"))) {
                ForEach(allTags, id: \.self) { tag in
                    // NavigationLink จะจัดการการไปหน้า CategoryResultView โดยอัตโนมัติ
                    // ไม่ต้องใช้ navigateTo ตรงนี้
                    NavigationLink(destination: CategoryResultView(selectedTag: tag, allPlaces: viewModel.places)) {
                        HStack(spacing: 15) {
                            Image(systemName: iconFor(tag: tag))
                                .foregroundColor(.purple)
                                .font(.system(size: 20))
                                .frame(width: 25, alignment: .center)
                            
                            Text(language.localized(tag, translateTag(th: tag)))
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(language.localized("ค้นหา", "Search")) // เปลี่ยนหัวข้อให้สั้นลง
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // --- 👇 แก้ไขตรงนี้ ---
                    flowManager.navigateBack() // ใช้ navigateBack() เพื่อย้อนกลับ
                    // --- 👆 สิ้นสุดส่วนแก้ไข ---
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(language.localized("กลับ", "Back"))
                    }
                }
            }
        }
        // ควร load view model ตอน onAppear
        .onAppear {
            if viewModel.places.isEmpty {
                viewModel.loadPlaces()
            }
        }
    }
    
    // ฟังก์ชันสำหรับกำหนดไอคอนตาม Tag (เหมือนเดิม)
    private func iconFor(tag: String) -> String {
        switch tag {
        case "การเรียน/การสอบ": return "graduationcap.fill"
        case "การงาน/ความสำเร็จ": return "briefcase.fill"
        case "ขอพร": return "hands.sparkles.fill"
        case "การเงิน/โชคลาภ": return "dollarsign.circle.fill"
        case "ค้าขาย": return "cart.fill"
        case "สุขภาพ": return "heart.fill"
        case "ความเจริญรุ่งเรือง": return "sparkles"
        case "แคล้วคลาดปลอดภัย": return "shield.lefthalf.filled"
        case "ความรัก/ครอบครัว": return "person.2.fill"
        case "เสริมดวง/แก้เคราะห์": return "wand.and.stars"
        default: return "tag.fill"
        }
    }
    
    // ฟังก์ชันสำหรับแปล Tag ภาษาไทยเป็นภาษาอังกฤษ (เหมือนเดิม)
    private func translateTag(th: String) -> String {
        switch th {
        case "การเรียน/การสอบ": return "Education/Exams"
        case "การงาน/ความสำเร็จ": return "Career/Success"
        case "ขอพร": return "Making a Wish"
        case "การเงิน/โชคลาภ": return "Finance/Luck"
        case "ค้าขาย": return "Business/Trade"
        case "สุขภาพ": return "Health"
        case "ความเจริญรุ่งเรือง": return "Prosperity"
        case "แคล้วคลาดปลอดภัย": return "Safety"
        case "ความรัก/ครอบครัว": return "Love/Family"
        case "เสริมดวง/แก้เคราะห์": return "Fortune Enhancement"
        default: return th
        }
    }
}
