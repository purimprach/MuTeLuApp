import SwiftUI

struct CarPlateView: View {
    @State private var plateNumber: String = ""
    @State private var result: (th: String, en: String)? = nil
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        ZStack {
            // MARK: - 1. พื้นหลังไล่ระดับสี
            LinearGradient(
                colors: [Color.blue.opacity(0.2), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - 2. Header
                VStack {
                    HStack {
                        BackButton()
                    }
                    Text("🚗 " + language.localized("ทำนายเลขทะเบียนรถ", "Car Plate Fortune"))
                        .font(.title).bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.blue.gradient)
                }
                
                // MARK: - 3. ช่องกรอกข้อมูลที่สวยขึ้น
                VStack {
                    TextField(language.localized("กรอกเฉพาะตัวเลขทะเบียน", "Enter plate numbers only"), text: $plateNumber)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                    
                    Text(language.localized("เช่น ทะเบียน 1กข 9872 ให้กรอกแค่ 9872", "e.g., for plate 1AB 9872, enter only 9872"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // MARK: - 4. ปุ่มทำนายที่ออกแบบใหม่
                Button(action: {
                    // ซ่อนคีย์บอร์ด
                    hideKeyboard()
                    // คำนวณผลรวม
                    let sum = calculatePlateSum(plateNumber)
                    // ดึงคำทำนาย
                    result = getPrediction(for: sum)
                }) {
                    Label(language.localized("ดูคำทำนาย", "Predict"), systemImage: "sparkles")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.gradient)
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.4), radius: 8, y: 4)
                }
                .disabled(plateNumber.isEmpty) // ปิดปุ่มถ้ายังไม่กรอก
                
                // MARK: - 5. การ์ดแสดงผลลัพธ์
                if let prediction = result {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(language.localized("ผลรวม: \(calculatePlateSum(plateNumber))", "Sum: \(calculatePlateSum(plateNumber))"), systemImage: "sum")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        
                        Divider()
                        
                        Text(language.localized(prediction.th, prediction.en))
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Functions
    
    private func calculatePlateSum(_ plate: String) -> Int {
        let digits = plate.compactMap { Int(String($0)) }
        guard !digits.isEmpty else { return 0 }
        
        let total = digits.reduce(0, +)
        // ทำให้ผลรวมเป็นเลขหลักเดียว (ถ้าต้องการ)
        // while total > 9 {
        //     total = String(total).compactMap { Int(String($0)) }.reduce(0, +)
        // }
        return total
    }
    
    private func getPrediction(for sum: Int) -> (th: String, en: String) {
        // คุณสามารถเพิ่มคำทำนายตามผลรวมต่างๆ ได้ที่นี่
        switch sum {
        case 1...9:
            return ("ผลรวมดีมาก ส่งเสริมด้านอำนาจบารมี", "Excellent sum, enhances prestige and power.")
        case 10...19:
            return ("ส่งเสริมด้านการเดินทางแคล้วคลาดปลอดภัย", "Promotes safe travels.")
        case 20...29:
            return ("ส่งเสริมด้านเมตตามหานิยม มีคนคอยช่วยเหลือ", "Enhances charm and attracts helpful people.")
        case 30...39:
            return ("ส่งเสริมด้านการค้าขายและโชคลาภทางการเงิน", "Boosts business and financial luck.")
        default:
            return ("เป็นเลขที่ดี มีพลังงานบวกอยู่รอบตัว", "A good number, surrounded by positive energy.")
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
