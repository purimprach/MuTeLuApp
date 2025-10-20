import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var activityStore: ActivityStore
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var userRecords: [ActivityRecord] = []
    
    var formatter: DateFormatter { /* ... (เหมือนเดิม) ... */
        let f = DateFormatter()
        f.dateStyle = .medium; f.timeStyle = .short
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        f.calendar = Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian)
        return f
    }
    
    var body: some View {
        if flowManager.isGuestMode {
            GuestLoginPromptView()
                .navigationTitle(language.localized("ประวัติการเช็คอิน", "Check-in History"))
                .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack {
                // --- 👇 [แก้ไข] เช็ค userRecords ที่นี่อีกครั้ง ---
                // เผื่อกรณี .onAppear โหลดข้อมูลไม่ทัน หรือมีการเปลี่ยนแปลง
                if userRecords.isEmpty {
                    // --- 👆 สิ้นสุด ---
                    Spacer()
                    Text(language.localized("ยังไม่มีประวัติการเช็คอิน", "No check-in history yet"))
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(userRecords) { record in
                            VStack(alignment: .leading) {
                                Text(language.currentLanguage == "th" ? record.placeNameTH : record.placeNameEN)
                                    .bold()
                                Text(formatter.string(from: record.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                if let points = record.meritPoints {
                                    Text("+\(points) \(language.localized("แต้มบุญ", "merit points"))")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .onAppear {
                // --- 👇 [แก้ไข] เพิ่มเงื่อนไข !isGuestMode ---
                // ดึงข้อมูล check-in เฉพาะเมื่อ Login อยู่เท่านั้น
                if !flowManager.isGuestMode {
                    userRecords = activityStore.checkInRecords(for: loggedInEmail)
                        .sorted { $0.date > $1.date }
                    print("📜 HistoryView: Loaded \(userRecords.count) records for \(loggedInEmail)")
                } else {
                    // ถ้าเป็น Guest ให้เคลียร์ข้อมูลเก่า (กันเหนียว)
                    userRecords = []
                    print("📜 HistoryView: In Guest Mode, clearing records.")
                }
            }
            .navigationTitle(language.localized("ประวัติการเช็คอิน", "Check-in History"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
