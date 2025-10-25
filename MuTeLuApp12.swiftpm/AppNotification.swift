import SwiftUI

struct AppNotification: Identifiable, Codable {
    let id: UUID
    let type: NotificationType 
    let titleTH: String
    let titleEN: String
    let messageTH: String
    let messageEN: String
    let timestamp: Date
    var isRead: Bool = false // สถานะอ่านแล้วหรือยัง
    let relatedPlaceID: String? // Optional: ถ้าเกี่ยวข้องกับสถานที่
    let relatedURL: String? // Optional: สำหรับเปิดหน้าเฉพาะเมื่อกดแจ้งเตือน
}

enum NotificationType: String, Codable {
    case holyDayReminder, holyDayToday
    case importantDayReminder, importantDayToday
    case checkInReady
    case dailyColor, dailyMantra, dailyTemple
    case gameChallenge, meritMilestone
    case newContent
    // เพิ่มประเภทอื่นๆ ตามต้องการ
}
