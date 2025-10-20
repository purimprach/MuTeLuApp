import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager // 👈 เพิ่มเข้ามา (มีอยู่แล้ว)
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @StateObject private var viewModel = SacredPlaceViewModel()
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // ... (bookmarkedRecords เหมือนเดิม) ...
    private var bookmarkedRecords: [BookmarkRecord] {
        bookmarkStore.getBookmarks(for: loggedInEmail)
    }
    
    var body: some View {
        // --- 👇 [เพิ่ม] เช็ค Guest Mode ---
        if flowManager.isGuestMode {
            GuestLoginPromptView() // ใช้ View เดิมจาก ProfileView
                .navigationTitle("📍 \(language.localized("สถานที่บันทึกไว้", "Bookmarked Places"))") // ใส่ Title
                .navigationBarTitleDisplayMode(.inline)
        } else {
            // --- แสดง Bookmarks ปกติ (โค้ดเดิม) ---
            VStack {
                if bookmarkedRecords.isEmpty {
                    Spacer()
                    Text(language.localized("คุณยังไม่ได้บันทึกสถานที่ใดๆ", "You haven't bookmarked any places yet."))
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(bookmarkedRecords) { record in
                        if let place = viewModel.places.first(where: { $0.id.uuidString == record.placeID }) {
                            BookmarkRow(place: place, record: record)
                                .onTapGesture {
                                    flowManager.navigateTo(.sacredDetail(place: place))
                                }
                                .environmentObject(language)
                        } else {
                            Text("Error: Place data not found for ID \(record.placeID)")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("📍 \(language.localized("สถานที่บันทึกไว้", "Bookmarked Places"))") // Title เดิม
            .navigationBarTitleDisplayMode(.inline) // Mode เดิม
            .onAppear {
                if viewModel.places.isEmpty {
                    viewModel.loadPlaces()
                }
            }
        } // End else (สำหรับ Login อยู่)
        // --- 👆 สิ้นสุดการเช็ค ---
    } // End body
} // End struct

// ... (BookmarkRow เหมือนเดิม) ...
struct BookmarkRow: View { /* ... */
    let place: SacredPlace; let record: BookmarkRecord
    @EnvironmentObject var language: AppLanguage
    private var dateFormatter: DateFormatter { /* ... */
        let formatter = DateFormatter()
        formatter.dateStyle = .medium; formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter
    }
    var body: some View {
        HStack(spacing: 15) {
            Image(uiImage: UIImage(named: place.imageName) ?? UIImage(systemName: "photo")!)
                .resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(12).clipped().foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 5) {
                Text(language.localized(place.nameTH, place.nameEN)).font(.headline).lineLimit(2)
                Text(language.localized("บันทึกเมื่อ: ", "Saved on: ") + dateFormatter.string(from: record.savedDate)).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary.opacity(0.5))
        }.padding(.vertical, 8)
    }
}
