import SwiftUI

struct RootWrapperView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var activityStore: ActivityStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    @EnvironmentObject var sacredPlaceViewModel: SacredPlaceViewModel
    
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
}
