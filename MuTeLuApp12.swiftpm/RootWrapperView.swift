import SwiftUI

struct RootWrapperView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var activityStore: ActivityStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    @EnvironmentObject var sacredPlaceViewModel: SacredPlaceViewModel
    @EnvironmentObject var notificationStore: NotificationStore
    @AppStorage("lastNotificationCheckDate") private var lastNotificationCheckDate: String = ""
    
    var body: some View {
        AppView()
            .onAppear {
                activityStore.loadActivities() // โหลด ActivityStore
                
                if !loggedInEmail.isEmpty {
                    // ถ้ามี email ที่จำไว้ ให้ถือว่า Login อยู่ และเริ่มที่ Home
                    print("👤 Found logged-in user: \(loggedInEmail), starting at Home.")
                    flowManager.isLoggedIn = true
                    flowManager.isGuestMode = false // ไม่ใช่ Guest
                    // ตั้งค่าหน้าจอเริ่มต้นและ Stack ให้ถูกต้อง
                    // (ถ้าค่า default ใน FlowManager คือ .login ให้เปลี่ยนตรงนี้)
                    if flowManager.currentScreen != .home { // ป้องกันการตั้งค่าซ้ำซ้อนถ้า default เป็น home แล้ว
                        flowManager.currentScreen = .home
                        flowManager.navigationStack = [.home]
                    }
                } else {
                    // ถ้าไม่มี email ที่จำไว้ ให้เริ่มที่หน้า Login (ซึ่งเป็นค่า default ใหม่)
                    print("🚪 No logged-in user found, starting at Login.")
                    flowManager.isLoggedIn = false
                    flowManager.isGuestMode = false // ยังไม่ใช่ Guest จนกว่าจะกดปุ่ม
                    // ตรวจสอบให้แน่ใจว่าเริ่มที่ Login จริงๆ
                    if flowManager.currentScreen != .login {
                        flowManager.currentScreen = .login
                        flowManager.navigationStack = [.login]
                    }
                }
                // --- 👆 สิ้นสุด ---
            }
            .preferredColorScheme(language.isDarkMode ? .dark : .light)
    }
    
    // --- vvv เพิ่มฟังก์ชันนี้ vvv ---
    private func checkAndCreateDateNotifications() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayString = ISO8601DateFormatter().string(from: today)
        
        // --- เช็คว่าวันนี้ได้เช็ค Notification ไปหรือยัง ---
        guard lastNotificationCheckDate != todayString else {
            print("ℹ️ Date notifications already checked today.")
            return // ถ้าเช็คไปแล้ว ไม่ต้องทำซ้ำ
        }
        print("🔍 Checking for Holy Day / Important Day notifications...")
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // --- 1. เช็ควันพระ ---
        let holyDays = loadBuddhistDays() // ใช้ฟังก์ชันเดิมจาก BuddhistDayBanner.swift
        // เช็ควันพระสำหรับ "พรุ่งนี้"
        if let nextHolyDay = holyDays.first(where: { calendar.isDate($0, inSameDayAs: tomorrow) }) {
            notificationStore.addNotification(
                type: .holyDayReminder,
                titleTH: "แจ้งเตือนวันพระ",
                titleEN: "Holy Day Reminder",
                messageTH: "พรุ่งนี้ (\(formattedDate(nextHolyDay))) เป็นวันพระ อย่าลืมทำบุญ สวดมนต์",
                messageEN: "Tomorrow (\(formattedDate(nextHolyDay))) is a Buddhist Holy Day. Remember to make merit."
            )
        }
        // เช็ควันพระสำหรับ "วันนี้"
        if holyDays.contains(where: { calendar.isDate($0, inSameDayAs: today) }) { // <-- แก้ไขบรรทัดนี้
            notificationStore.addNotification(
                type: .holyDayToday,
                titleTH: "วันนี้วันพระ",
                titleEN: "Today is Holy Day",
                messageTH: "อย่าลืมทำบุญ สวดมนต์ หรือปฏิบัติธรรม",
                messageEN: "Remember to make merit, pray, or practice mindfulness."
            )
        }
        
        
        // --- 2. เช็ควันสำคัญ ---
        let importantDays = loadImportantReligiousDays() // ใช้ฟังก์ชันเดิมจาก ReligiousHolidayBanner.swift
        // เช็ควันสำคัญสำหรับ "พรุ่งนี้"
        if let nextImportantDay = importantDays.first(where: { calendar.isDate($0.date, inSameDayAs: tomorrow) }) {
            notificationStore.addNotification(
                type: .importantDayReminder,
                titleTH: "แจ้งเตือนวันสำคัญ",
                titleEN: "Important Day Reminder",
                messageTH: "พรุ่งนี้เป็น\(language.localized(nextImportantDay.nameTH, nextImportantDay.nameEN))",
                messageEN: "Tomorrow is \(language.localized(nextImportantDay.nameTH, nextImportantDay.nameEN))"
            )
        }
        // เช็ควันสำคัญสำหรับ "วันนี้"
        if importantDays.contains(where: { calendar.isDate($0.date, inSameDayAs: today) }) { // <-- แก้ไขบรรทัดนี้
            // --- ดึงข้อมูลวันสำคัญที่ตรงออกมาใช้ ---
            if let todayImportantDayInfo = importantDays.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
                notificationStore.addNotification(
                    type: .importantDayToday,
                    titleTH: "วันนี้เป็นวันสำคัญ",
                    titleEN: "Today is an Important Day",
                    messageTH: "\(language.localized(todayImportantDayInfo.nameTH, todayImportantDayInfo.nameEN))", // <-- ใช้ข้อมูลที่ดึงมา
                    messageEN: "\(language.localized(todayImportantDayInfo.nameTH, todayImportantDayInfo.nameEN))" // <-- ใช้ข้อมูลที่ดึงมา
                )
            }
        }
        
        
        // --- บันทึกว่าวันนี้ได้เช็ค Notification ไปแล้ว ---
        lastNotificationCheckDate = todayString
        print("✅ Finished checking date notifications.")
    }
    
    // ฟังก์ชัน format วันที่ (อาจจะเอามาจาก Banner หรือสร้างใหม่)
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.dateStyle = .medium // หรือ .short ถ้าต้องการสั้นๆ
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
} // End Struct

