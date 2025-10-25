import Foundation
import SwiftUI // Import SwiftUI เพื่อใช้ @MainActor และ ObservableObject

@MainActor // ทำให้แน่ใจว่าการเปลี่ยนแปลง @Published เกิดขึ้นบน Main Thread
class NotificationStore: ObservableObject {
    
    @Published var notifications: [AppNotification] = [] {
        didSet {
            // บันทึกทุกครั้งที่มีการเปลี่ยนแปลง notifications array
            saveNotifications()
        }
    }
    
    private let storageKey = "user_notifications_v1" // Key สำหรับบันทึกใน UserDefaults
    
    init() {
        // โหลดข้อมูลที่เคยบันทึกไว้ตอนที่ Store ถูกสร้างขึ้น
        loadNotifications()
    }
    
    // --- ฟังก์ชันสำหรับจัดการ Notifications ---
    
    /// เพิ่ม Notification ใหม่ (จะเพิ่มไว้บนสุดของ List)
    func addNotification(type: NotificationType, titleTH: String, titleEN: String, messageTH: String, messageEN: String, relatedPlaceID: String? = nil, relatedURL: String? = nil) {
        let newNotification = AppNotification(
            id: UUID(),
            type: type,
            titleTH: titleTH,
            titleEN: titleEN,
            messageTH: messageTH,
            messageEN: messageEN,
            timestamp: Date(), // ใช้เวลาปัจจุบัน
            isRead: false,    // Notification ใหม่ยังไม่ได้อ่าน
            relatedPlaceID: relatedPlaceID,
            relatedURL: relatedURL
        )
        
        // Insert ไว้ที่ index 0 เพื่อให้รายการล่าสุดอยู่บนสุด
        notifications.insert(newNotification, at: 0)
        
        // จำกัดจำนวน Notification สูงสุด (ถ้าต้องการ, เช่น เก็บแค่ 100 รายการล่าสุด)
        // if notifications.count > 100 {
        //     notifications.removeLast(notifications.count - 100)
        // }
        
        print("🔔 Added Notification: \(titleTH)")
    }
    
    /// อัปเดตสถานะ isRead ของ Notification
    func markAsRead(notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            if !notifications[index].isRead { // เช็คก่อนว่ายังไม่ได้อ่าน ค่อยเปลี่ยน
                notifications[index].isRead = true
                print("📖 Marked Notification as Read: \(notifications[index].titleTH)")
            }
        }
    }
    
    /// อัปเดตสถานะ isRead ของ Notification หลายรายการ
    func markMultipleAsRead(notificationIds: Set<UUID>) {
        var changed = false
        for index in notifications.indices {
            if notificationIds.contains(notifications[index].id) && !notifications[index].isRead {
                notifications[index].isRead = true
                changed = true
            }
        }
        if changed {
            print("📖 Marked \(notificationIds.count) Notifications as Read")
        }
    }
    
    
    /// ลบ Notification ที่อ่านแล้วทั้งหมด
    func clearReadNotifications() {
        let initialCount = notifications.count
        notifications.removeAll { $0.isRead }
        let removedCount = initialCount - notifications.count
        if removedCount > 0 {
            print("🗑️ Cleared \(removedCount) Read Notifications")
        }
    }
    
    /// ลบ Notification ทั้งหมด (อาจจะเพิ่มปุ่มนี้ในหน้า Settings)
    func clearAllNotifications() {
        if !notifications.isEmpty {
            notifications.removeAll()
            print("🗑️ Cleared All Notifications")
        }
    }
    
    
    // --- ฟังก์ชันสำหรับการบันทึกและโหลดข้อมูล ---
    
    /// บันทึก Notifications Array ลง UserDefaults
    private func saveNotifications() {
        // ใช้ JSONEncoder เพื่อแปลง Array เป็น Data
        if let encodedData = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encodedData, forKey: storageKey)
            // print("💾 Saved \(notifications.count) notifications.") // Optional: uncomment for debugging
        } else {
            print("❌ Error saving notifications.")
        }
    }
    
    /// โหลด Notifications Array จาก UserDefaults
    private func loadNotifications() {
        // ใช้ JSONDecoder เพื่อแปลง Data กลับเป็น Array
        if let savedData = UserDefaults.standard.data(forKey: storageKey) {
            if let decodedNotifications = try? JSONDecoder().decode([AppNotification].self, from: savedData) {
                notifications = decodedNotifications
                print("✅ Loaded \(notifications.count) notifications.")
                return // โหลดสำเร็จ ออกจากฟังก์ชัน
            } else {
                print("⚠️ Error decoding notifications. Data might be corrupted.")
                // ถ้า decode ไม่ได้ อาจจะลองลบข้อมูลเก่าทิ้ง
                UserDefaults.standard.removeObject(forKey: storageKey)
            }
        }
        // ถ้าไม่มีข้อมูลเก่า หรือ decode ไม่ได้ ให้เริ่มด้วย array ว่าง
        notifications = []
        print("ℹ️ No saved notifications found or data corrupted. Starting fresh.")
    }
}
