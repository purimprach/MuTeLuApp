import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @StateObject private var viewModel = SacredPlaceViewModel() // ต้องมีเพื่อให้หา place ได้
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // ดึงรายการที่บันทึกไว้ของผู้ใช้คนปัจจุบัน
    private var bookmarkedRecords: [BookmarkRecord] {
        bookmarkStore.getBookmarks(for: loggedInEmail)
    }
    
    var body: some View {
        VStack {
            // (ส่วน Header และปุ่ม "ย้อนกลับ" ที่เคยลบไป ถูกต้องแล้ว)
            
            if bookmarkedRecords.isEmpty {
                Spacer()
                Text(language.localized("คุณยังไม่ได้บันทึกสถานที่ใดๆ", "You haven't bookmarked any places yet."))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(bookmarkedRecords) { record in
                    // หาข้อมูลสถานที่เต็มๆ จาก ID ที่บันทึกไว้
                    if let place = viewModel.places.first(where: { $0.id.uuidString == record.placeID }) {
                        BookmarkRow(place: place, record: record)
                            .onTapGesture {
                                // --- 👇 แก้ไขตรงนี้ ---
                                flowManager.navigateTo(.sacredDetail(place: place)) // ใช้ navigateTo
                                // --- 👆 สิ้นสุดส่วนแก้ไข ---
                            }
                        // ส่ง EnvironmentObjects ที่จำเป็นให้ BookmarkRow ด้วย
                            .environmentObject(language)
                    } else {
                        // อาจจะแสดงข้อความว่าไม่พบข้อมูลสถานที่
                        Text("Error: Place data not found for ID \(record.placeID)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("📍 \(language.localized("สถานที่บันทึกไว้", "Bookmarked Places"))")
        .navigationBarTitleDisplayMode(.inline)
        // ควรจะ load view model ตอน onAppear ถ้ายังไม่ได้ load ที่อื่น
        .onAppear {
            if viewModel.places.isEmpty {
                viewModel.loadPlaces() // หรือเรียกใช้ฟังก์ชัน load ข้อมูลของคุณ
            }
        }
    }
}

// --- Subview สำหรับแสดงผล 1 รายการ (BookmarkRow) ---
// (โค้ดส่วนนี้ไม่มีการเปลี่ยนแปลง นอกจากรับ EnvironmentObject เพิ่ม)
struct BookmarkRow: View {
    let place: SacredPlace
    let record: BookmarkRecord
    @EnvironmentObject var language: AppLanguage // รับ language มาใช้
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // ควรตรวจสอบว่ามีรูปภาพหรือไม่ก่อนแสดง
            Image(uiImage: UIImage(named: place.imageName) ?? UIImage(systemName: "photo")!) // ใช้ placeholder ถ้าไม่มีรูป
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()
                .foregroundColor(.gray) // สีสำหรับ placeholder
            
            VStack(alignment: .leading, spacing: 5) {
                Text(language.localized(place.nameTH, place.nameEN))
                    .font(.headline)
                    .lineLimit(2)
                
                Text(language.localized("บันทึกเมื่อ: ", "Saved on: ") + dateFormatter.string(from: record.savedDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}
