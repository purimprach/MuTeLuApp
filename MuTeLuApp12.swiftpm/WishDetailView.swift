import SwiftUI

struct WishDetailView: View {
    @EnvironmentObject var flow: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: {
                        flow.currentScreen = .home
                    }) {
                        Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                            .font(.headline)
                            .padding(.bottom, -5)
                    }
                    Spacer()
                }
                
                Group {
                    Text("🙏 การกล่าวขอพรตามความเชื่อส่วนบุคคล")
                        .font(.headline)
                        .bold()
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.5), lineWidth: 2)
                        )
                    
                    Text("(โปรดใช้วิจารณญาณในการศึกษา)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("การไหว้ขอพรสิ่งศักดิ์สิทธิ์ที่เราศรัทธานั้น อาจแบ่งออกได้เป็น 3 กลุ่มหลัก ได้แก่:")
                    
                    Text("• สายพุทธ (พระพุทธเจ้า พระอรหันต์)")
                    Text("• สายอินดู (พระพรหม พระพิฆเนศ พระศิวะ ฯลฯ)")
                    Text("• สายบุคคล (ครูบาอาจารย์ บรรพบุรุษ หรือบุคคลผู้มีคุณธรรม)")
                }
                
                Group {
                    Text("🗣️ วิธีการขอพร")
                        .font(.headline)
                        .bold()
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.5), lineWidth: 2)
                        )
                    
                    Text("หลังจากกล่าวคำนอบน้อม หรือถวายเครื่องสักการะแล้ว สามารถกล่าวขอพรต่อหน้าสิ่งศักดิ์สิทธิ์ด้วยคำพูดของตนเอง โดยอาจใช้โครงสร้างดังนี้:")
                    
                    Text("ข้าพเจ้า นาย/นาง/นางสาว [ชื่อ-นามสกุล] ขอกราบขอพรเพื่อบารมีของ [ชื่อสิ่งศักดิ์สิทธิ์หรือสถานที่] โปรดดลบันดาลให้ข้าพเจ้าประสบความสำเร็จในเรื่อง [สิ่งที่ปรารถนา]")
                        .foregroundColor(.red)
                    
                    Text("หากมีรายละเอียดเพิ่มเติม ให้กล่าวต่อได้เลย")
                    
                    Text("“เมื่อความปรารถนาสำเร็จ ข้าพเจ้าจะ [ของที่ใช้แก้บน] มาถวายเป็นการแก้บนตามคำสัจจะ”")
                        .foregroundColor(.red)
                }
                
                Group {
                    Text("🎯 ตัวอย่างการขอพร")
                        .font(.headline)
                        .bold()
                        .padding()
                    
                    Text("“ข้าพเจ้า นางสาวนาถลดา สมมติสกุล ขอกราบขอพรเพื่อบารมีของพระตรีมูรติ และสิ่งศักดิ์สิทธิ์ทั้งหลาย ขอให้ข้าพเจ้าสำเร็จตามสิ่งที่ตั้งใจ”")
                        .italic()
                }
                
                Group {
                    Text("✨ หลักสำคัญของการขอพรให้สำเร็จ")
                        .font(.headline)
                        .bold()
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.5), lineWidth: 2)
                        )
                    
                    Text("1. จิตใจแน่วแน่\n2. เชื่อมั่นศรัทธา\n3. ประพฤติดีอย่างสม่ำเสมอ")
                    Text("✅ ขณะขอพร ควรมีสมาธิ ใจนิ่ง มั่นคง และมุ่งมั่นกับสิ่งที่ขอ ไม่ลังเล ไม่ออกนอกเรื่อง\n✅ จงกระทำความดีอย่างจริงใจ หมั่นสร้างบุญกุศล ไม่เบียดเบียนผู้อื่น\n✅ สิ่งศักดิ์สิทธิ์จะช่วยอำนวยพรแก่ผู้ที่เหมาะสมเท่านั้น")
                }
            }
            .padding()
        }
        .navigationTitle("หลักการขอพร")
    }
}
