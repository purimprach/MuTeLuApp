import SwiftUI

struct MeritPointsView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // 👈 เพิ่มเข้ามา
    @EnvironmentObject var activityStore: ActivityStore
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var userRecords: [ActivityRecord] = []
    
    // ... (dateFormatter เหมือนเดิม) ...
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.calendar = Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian)
        return formatter
    }
    
    var totalPoints: Int {
        activityStore.totalMeritPoints(for: loggedInEmail)
    }
    
    var body: some View {
        // --- 👇 [เพิ่ม] เช็ค Guest Mode ---
        if flowManager.isGuestMode {
            GuestLoginPromptView() // ใช้ View เดิมจาก ProfileView
                .navigationTitle(language.localized("คะแนนแต้มบุญ", "Merit Points")) // ใส่ Title
                .navigationBarTitleDisplayMode(.inline)
        } else {
            // --- แสดง Merit Points ปกติ (โค้ดเดิม) ---
            VStack(spacing: 16) {
                BackButton()
                VStack(spacing: 8) {
                    Text(language.localized("คะแนนแต้มบุญทั้งหมด", "Total Merit Points"))
                        .font(.headline)
                    
                    Text("\(totalPoints) 🟣")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.purple)
                }
                .padding(.top)
                
                if userRecords.isEmpty {
                    Spacer()
                    Text(language.localized("ยังไม่มีประวัติแต้มบุญ", "No merit history yet"))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(userRecords) { record in
                            // แสดงเฉพาะ checkIn ที่มีแต้ม
                            if record.type == .checkIn, let points = record.meritPoints, points > 0 {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(language.currentLanguage == "th" ? record.placeNameTH : record.placeNameEN)
                                        .font(.headline)
                                    Text(dateFormatter.string(from: record.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("+\(points) \(language.localized("แต้ม", "points"))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    } // End List
                } // End else
            } // End VStack หลัก
            .padding(.top)
            .onAppear {
                // ดึงข้อมูลจาก ActivityStore (เหมือนเดิม)
                userRecords = activityStore.checkInRecords(for: loggedInEmail).sorted { $0.date > $1.date }
            }
            // --- 👇 [เพิ่ม] ใส่ Title ---
            .navigationTitle(language.localized("คะแนนแต้มบุญ", "Merit Points"))
            .navigationBarTitleDisplayMode(.inline)
            // --- 👆 สิ้นสุด ---
        } // End else (สำหรับ Login อยู่)
        // --- 👆 สิ้นสุดการเช็ค ---
    } // End body
} // End struct
