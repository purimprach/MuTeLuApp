import SwiftUI

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var notificationStore: NotificationStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var sacredPlaceViewModel: SacredPlaceViewModel // เพิ่ม ViewModel สำหรับหา Place
    
    // State สำหรับควบคุมการแสดง Action Sheet
    @State private var showingClearOptions = false
    // State สำหรับติดตามว่ามี Notification ที่ยังไม่ได้อ่านหรือไม่
    @State private var hasUnreadNotifications = false
    
    var body: some View {
        // ใช้ NavigationStack เพื่อให้มี Title Bar และปุ่ม
        NavigationStack {
            VStack {
                if notificationStore.notifications.isEmpty {
                    // --- กรณีไม่มี Notification ---
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text(language.localized("ไม่มีการแจ้งเตือน", "No Notifications"))
                            .font(.title3.bold())
                            .foregroundColor(.secondary)
                        Text(language.localized("การแจ้งเตือนใหม่ๆ จะปรากฏที่นี่", "New notifications will appear here."))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Spacer()
                } else {
                    // --- กรณีมี Notification ---
                    List {
                        ForEach(notificationStore.notifications) { notification in
                            NotificationRow(notification: notification)
                                .contentShape(Rectangle()) // ทำให้กดได้ทั้งแถว
                                .onTapGesture {
                                    handleTap(on: notification)
                                }
                            // เพิ่ม Swipe Action (ถ้าต้องการ)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        notificationStore.markAsRead(notificationId: notification.id)
                                    } label: {
                                        Label(language.localized("อ่านแล้ว", "Mark Read"), systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.blue) // สีปุ่ม Mark Read
                                }
                            // สามารถเพิ่ม Swipe Action สำหรับลบได้ (ถ้าต้องการ)
                            // .swipeActions(edge: .trailing) { ... }
                        }
                        // เพิ่ม onDelele ถ้าต้องการให้ลบทีละรายการได้
                        // .onDelete(perform: deleteNotification)
                    }
                    .listStyle(.plain) // หรือ .insetGrouped ถ้าชอบ
                }
            }
            .navigationTitle(language.localized("การแจ้งเตือน", "Notifications"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ปุ่มสำหรับ Clear Notifications (แสดงเมื่อมี Notification เท่านั้น)
                if !notificationStore.notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingClearOptions = true
                        } label: {
                            Image(systemName: "trash") // ไอคอนถังขยะ
                        }
                        // Action Sheet ถามว่าจะลบแบบไหน
                        .confirmationDialog(
                            language.localized("ล้างการแจ้งเตือน", "Clear Notifications"),
                            isPresented: $showingClearOptions,
                            titleVisibility: .visible
                        ) {
                            Button(language.localized("ล้างรายการที่อ่านแล้ว", "Clear Read Items"), role: .destructive) {
                                notificationStore.clearReadNotifications()
                            }
                            Button(language.localized("ล้างทั้งหมด", "Clear All"), role: .destructive) {
                                notificationStore.clearAllNotifications()
                            }
                            Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
                        }
                    }
                }
                
                // (Optional) ปุ่ม Mark All Read (แสดงเมื่อมี Unread)
                if hasUnreadNotifications {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(language.localized("อ่านทั้งหมด", "Mark All Read")) {
                            let unreadIDs = Set(notificationStore.notifications.filter { !$0.isRead }.map { $0.id })
                            notificationStore.markMultipleAsRead(notificationIds: unreadIDs)
                        }
                    }
                }
            }
            // เช็คสถานะ Unread ตลอดเวลา
            .onReceive(notificationStore.$notifications) { notifications in
                hasUnreadNotifications = notifications.contains { !$0.isRead }
            }
        } // End NavigationStack
    } // End Body
    
    // --- ฟังก์ชันช่วยเหลือ ---
    
    /// จัดการเมื่อผู้ใช้แตะที่ Notification Row
    private func handleTap(on notification: AppNotification) {
        // 1. Mark as Read ก่อนเสมอ
        notificationStore.markAsRead(notificationId: notification.id)
        
        // 2. ตรวจสอบว่ามี Action ที่ต้องทำต่อหรือไม่
        if let placeIDString = notification.relatedPlaceID,
           let placeID = UUID(uuidString: placeIDString),
           let place = sacredPlaceViewModel.places.first(where: { $0.id == placeID }) {
            // ถ้ามี PlaceID และหา Place เจอ -> Navigate ไปหน้า Detail
            flowManager.navigateTo(.sacredDetail(place: place))
        } else if let urlString = notification.relatedURL, let url = URL(string: urlString) {
            // ถ้ามี URL -> เปิด URL (อาจจะต้องเช็คก่อนว่าเป็น URL ภายในแอปหรือไม่)
            // เบื้องต้นเปิดใน Safari ไปก่อน
            UIApplication.shared.open(url)
        }
        // ถ้าไม่มีทั้ง PlaceID และ URL ก็ไม่ต้องทำอะไรต่อ (แค่ Mark Read)
    }
    
    /// (Optional) ฟังก์ชันสำหรับลบ Notification (ถ้าใช้ .onDelete)
    // private func deleteNotification(at offsets: IndexSet) {
    //     let idsToDelete = offsets.map { notificationStore.notifications[$0].id }
    //     notificationStore.notifications.remove(atOffsets: offsets)
    //     // อาจจะบันทึกการลบ หรือทำอย่างอื่นเพิ่มเติม
    // }
    
} // End Struct

// MARK: - Notification Row Subview

struct NotificationRow: View {
    let notification: AppNotification
    @EnvironmentObject var language: AppLanguage
    
    // Formatter สำหรับแสดงเวลา
    private var relativeFormatter: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full // เช่น "5 minutes ago", "1 day ago"
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon ตามประเภท
            Image(systemName: iconName(for: notification.type))
                .font(.title2)
                .foregroundColor(iconColor(for: notification.type))
                .frame(width: 30, alignment: .center) // จัดให้ Icon กว้างเท่าๆ กัน
            
            // ส่วนข้อความ
            VStack(alignment: .leading, spacing: 4) {
                Text(language.localized(notification.titleTH, notification.titleEN))
                    .font(.headline)
                    .lineLimit(2) // จำกัด Title ไม่เกิน 2 บรรทัด
                
                Text(language.localized(notification.messageTH, notification.messageEN))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3) // จำกัด Message ไม่เกิน 3 บรรทัด
                
                Text(relativeFormatter.localizedString(for: notification.timestamp, relativeTo: Date()))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer() // ดัน Indicator ไปทางขวา
            
            // Read Indicator (จุดสีฟ้า)
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                // .padding(.trailing, 4) // อาจจะเพิ่ม Padding ถ้าต้องการ
            }
        }
        .padding(.vertical, 8) // เพิ่ม Padding บนล่างให้แต่ละ Row
    }
    
    // --- Helper functions for Icon and Color ---
    private func iconName(for type: NotificationType) -> String {
        switch type {
        case .holyDayReminder, .holyDayToday:
            return "calendar.badge.clock"
        case .importantDayReminder, .importantDayToday:
            return "sparkles"
        case .checkInReady:
            return "checkmark.seal.fill"
        case .dailyColor:
            return "tshirt.fill"
        case .dailyMantra:
            return "music.quarternote.3"
        case .dailyTemple:
            return "building.columns.fill"
        case .gameChallenge:
            return "gamecontroller.fill"
        case .meritMilestone:
            return "star.fill"
        case .newContent:
            return "doc.text.fill"
        }
    }
    
    private func iconColor(for type: NotificationType) -> Color {
        switch type {
        case .holyDayReminder, .holyDayToday:
            return .red
        case .importantDayReminder, .importantDayToday:
            return .blue
        case .checkInReady:
            return .green
        case .dailyColor, .dailyMantra, .dailyTemple:
            return .purple
        case .gameChallenge, .meritMilestone:
            return .orange
        case .newContent:
            return .cyan
        }
    }
} // End NotificationRow

// MARK: - Preview

#Preview {
    // สร้างข้อมูล Mock สำหรับ Preview
    let mockStore = NotificationStore()
    mockStore.addNotification(type: .holyDayReminder, titleTH: "วันพระพรุ่งนี้", titleEN: "Holy Day Tomorrow", messageTH: "เตรียมตัวทำบุญ สวดมนต์", messageEN: "Prepare for merit making")
    mockStore.addNotification(type: .checkInReady, titleTH: "เช็คอินได้แล้ว", titleEN: "Check-in Ready", messageTH: "กลับไปเช็คอินที่วัด A ได้", messageEN: "You can check-in at Wat A again", relatedPlaceID: UUID().uuidString) // ใส่ PlaceID สมมติ
    mockStore.notifications[1].isRead = true // สมมติว่าอันที่สองอ่านแล้ว
    
    return NotificationView()
        .environmentObject(mockStore)
        .environmentObject(AppLanguage())
        .environmentObject(MuTeLuFlowManager())
        .environmentObject(SacredPlaceViewModel()) // ต้องใส่ ViewModel ด้วย
}
