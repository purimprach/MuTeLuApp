import SwiftUI

struct BackButton: View {
    // EnvironmentObject เดิม ยังคงใช้เหมือนเดิม
    @EnvironmentObject var flow: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        HStack {
            Button(action: {
                // --- 👇 เปลี่ยน action ตรงนี้ ---
                flow.navigateBack() // เรียกใช้ฟังก์ชันย้อนกลับที่เราสร้างไว้
                // --- 👆 สิ้นสุดส่วนที่เปลี่ยน ---
            }) {
                Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                    .font(.headline)
                    .padding(.bottom, -5) // ส่วน padding เดิม ไม่ต้องแก้
            }
            .padding(.top) 
            Spacer()
        }
        .padding(.horizontal) // ส่วน padding เดิม ไม่ต้องแก้
    }
}
