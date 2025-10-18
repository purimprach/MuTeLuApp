import SwiftUI

struct WishDetailView: View {
    @EnvironmentObject var flow: MuTeLuFlowManager // รับ flowManager (ชื่อ flow ใน Environment)
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // --- 👇 จุดแก้ไข ---
                // ใช้ BackButton component แทน HStack เดิม
                BackButton()
                // --- 👆 สิ้นสุดส่วนแก้ไข ---
                
                // --- ส่วนเนื้อหา (เหมือนเดิม) ---
                Group {
                    Text("🙏 การกล่าวขอพรตามความเชื่อส่วนบุคคล")
                        .font(.headline)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center) // ทำให้ข้อความอยู่กลาง
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.7), lineWidth: 1.5) // ปรับสีและความหนาเส้น
                        )
                    
                    Text("(โปรดใช้วิจารณญาณในการศึกษา)")
                        .font(.subheadline)
                        .foregroundColor(.secondary) // ใช้ .secondary ดูดีกว่า .gray
                        .frame(maxWidth: .infinity, alignment: .center) // ทำให้ข้อความอยู่กลาง
                    
                    Text("การไหว้ขอพรสิ่งศักดิ์สิทธิ์ที่เราศรัทธานั้น อาจแบ่งออกได้เป็น 3 กลุ่มหลัก ได้แก่:")
                        .font(.body) // กำหนด font size
                    
                    // ใช้ VStack และ Label เพื่อจัดรูปแบบให้สวยขึ้น
                    VStack(alignment: .leading, spacing: 8) {
                        Label("สายพุทธ (พระพุทธเจ้า พระอรหันต์)", systemImage: "figure.walk") // ใช้ icon ที่สื่อ
                        Label("สายฮินดู (พระพรหม พระพิฆเนศ พระศิวะ ฯลฯ)", systemImage: "flame") // ใช้ icon ที่สื่อ
                        Label("สายบุคคล (ครูบาอาจารย์ บรรพบุรุษ หรือบุคคลผู้มีคุณธรรม)", systemImage: "person.2") // ใช้ icon ที่สื่อ
                    }
                    .padding(.leading)
                }
                .padding(.bottom, 10) // เพิ่มระยะห่างท้าย Group
                
                Divider() // เพิ่มเส้นคั่น
                
                Group {
                    Text("🗣️ วิธีการขอพร")
                        .font(.headline)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.7), lineWidth: 1.5)
                        )
                    
                    Text("หลังจากกล่าวคำนอบน้อม หรือถวายเครื่องสักการะแล้ว สามารถกล่าวขอพรต่อหน้าสิ่งศักดิ์สิทธิ์ด้วยคำพูดของตนเอง โดยอาจใช้โครงสร้างดังนี้:")
                        .font(.body)
                    
                    // ใช้ Text แบบ Markdown เพื่อเน้นข้อความ
                    Text("""
                         "ข้าพเจ้า นาย/นาง/นางสาว **[ชื่อ-นามสกุล]** ขอกราบขอพรเพื่อบารมีของ **[ชื่อสิ่งศักดิ์สิทธิ์หรือสถานที่]** โปรดดลบันดาลให้ข้าพเจ้าประสบความสำเร็จในเรื่อง **[สิ่งที่ปรารถนา]**"
                         """)
                    .font(.body.italic()) // ทำให้เป็นตัวเอียง
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.05)) // เพิ่มพื้นหลังอ่อนๆ
                    .cornerRadius(8)
                    
                    
                    Text("หากมีการบนบานเพิ่มเติม ให้กล่าวต่อว่า:") // แก้ไขข้อความตามไฟล์ Wish.txt
                        .font(.body)
                    
                    Text("""
                         "เมื่อความปรารถนานี้สำเร็จ ข้าพเจ้าจะนำ **[ของที่ใช้แก้บน]** มาถวายเป็นการแก้บนบานตามสัจจะ"
                         """)
                    .font(.body.italic())
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.05))
                    .cornerRadius(8)
                }
                .padding(.bottom, 10)
                
                Divider()
                
                Group {
                    Text("🎯 ตัวอย่างการขอพร")
                        .font(.headline)
                        .bold()
                        .padding(.bottom, 5) // ลดระยะห่างด้านล่าง
                    
                    // ใช้ Text แบบยาวจากไฟล์ Wish.txt
                    Text("""
                        "ข้าพเจ้า นางสาวเมตตา สมมติสกุล
                        ขอกราบพึ่งพระบารมีของพระพุทธองค์
                        และสิ่งศักดิ์สิทธิ์ทั้งหลาย ณ วัดแห่งนี้
                        โปรดเมตตาอำนวยพรให้ข้าพเจ้าสอบติด
                        คณะพาณิชยศาสตร์และการบัญชี
                        จุฬาลงกรณ์มหาวิทยาลัยได้สำเร็จ
                        เพื่อข้าพเจ้าจะได้ตอบแทนบุญคุณครอบครัว
                        และเป็นผู้มีคุณประโยชน์ต่อสังคมต่อไป"
                        """)
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.05)) // ใช้สีต่างกันเล็กน้อย
                    .cornerRadius(8)
                    
                    Text("(หากยังไม่แน่ใจในชื่อคณะหรือมหาวิทยาลัย สามารถเว้นวรรคไว้ได้)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                Divider()
                
                Group {
                    Text("✨ หลักสำคัญของการขอพรให้สำเร็จ (ตามความเชื่อ)") // แก้ไขข้อความตามไฟล์ Wish.txt
                        .font(.headline)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.7), lineWidth: 1.5)
                        )
                    
                    // ใช้ VStack และ Text แยกบรรทัด
                    VStack(alignment: .leading, spacing: 5) {
                        Text("1. จิตใจแน่วแน่")
                        Text("2. เชื่อมั่นศรัทธา")
                        Text("3. ประพฤติดีอย่างสม่ำเสมอ")
                    }
                    .font(.body.weight(.medium)) // ทำตัวหนาเล็กน้อย
                    .padding(.leading)
                    .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("ขณะขอพร ควรมีสมาธิ ใจนิ่ง มั่นคง และมุ่งมั่นกับสิ่งที่ขอ ไม่ลังเล ไม่วอกแวก", systemImage: "checkmark.circle.fill") // ใช้ icon checkmark
                            .foregroundColor(.green)
                        Label("ความเชื่อในสิ่งศักดิ์สิทธิ์คือหัวใจสำคัญ หากไม่เชื่อจริง พรก็ยากจะสำเร็จ", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Label("จงกระทำความดีอย่างจริงใจ หมั่นสร้างบุญกุศล ไม่เบียดเบียนผู้อื่น", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Label("สิ่งศักดิ์สิทธิ์จะช่วยอำนวยพรแก่ผู้ที่เหมาะสมเท่านั้น", systemImage: "lightbulb.fill") // ใช้ icon อื่น
                            .foregroundColor(.orange)
                    }
                    .font(.subheadline) // ปรับขนาด font
                    .padding(.leading)
                }
            }
            .padding() 
        }
    }
}

// Preview (ควรใส่)
#Preview {
    NavigationView { // ใส่ NavigationView เพื่อให้ BackButton ทำงานใน Preview
        WishDetailView()
            .environmentObject(AppLanguage())
            .environmentObject(MuTeLuFlowManager())
    }
}
