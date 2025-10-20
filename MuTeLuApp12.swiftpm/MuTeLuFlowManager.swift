import Foundation

// MARK: - Flow Manager (ตัวจัดการการเปลี่ยนหน้า)
class MuTeLuFlowManager: ObservableObject {
    @Published var currentScreen: MuTeLuScreen = .login // 👈 **เปลี่ยนค่าเริ่มต้นเป็น .login**
    @Published var isLoggedIn: Bool = false
    @Published var isGuestMode: Bool = false
    @Published var navigationStack: [MuTeLuScreen] = [.login] // 👈 **เปลี่ยนค่าเริ่มต้นเป็น .login**
    
    /// ฟังก์ชันสำหรับเปลี่ยนไปหน้าจอใหม่ และเพิ่มลงในประวัติ (stack)
    func navigateTo(_ screen: MuTeLuScreen) {
        if navigationStack.last != screen {
            navigationStack.append(screen)
        }
        currentScreen = screen
        // --- 👇 [เพิ่ม] ถ้าไปหน้าไหนก็ตามที่ไม่ใช่ Login/Register ให้ถือว่าไม่ใช่ Guest Mode อีกต่อไป (ยกเว้น Home) ---
        if screen != .login && screen != .registration && screen != .home {
            // ถ้ามีการ navigate ไปหน้าอื่น ๆ หลังจากเข้า Guest Mode แล้ว
            // และผู้ใช้ยังไม่ได้ Login จริงๆ อาจจะต้องพิจารณาว่าจะบังคับ Login หรือไม่
            // แต่เบื้องต้น การตั้ง isGuestMode = false ตรงนี้อาจไม่จำเป็นเสมอไป
            // อาจจะเช็ค isGuestMode ใน View ที่ต้องการจำกัดฟีเจอร์แทน
            // isGuestMode = false // <--- ลอง comment บรรทัดนี้ไว้ก่อน
        }
    }
    
    /// ฟังก์ชันสำหรับย้อนกลับไปยังหน้าจอก่อนหน้าในประวัติ (stack)
    func navigateBack() {
        if navigationStack.count > 1 {
            navigationStack.removeLast()
            currentScreen = navigationStack.last ?? (isLoggedIn || isGuestMode ? .home : .login) // 👈 ปรับ Default Fallback
        } else {
            // ถ้าเหลือหน้าเดียว ให้กลับไป Home (ถ้า Login/Guest) หรือ Login (ถ้ายังไม่ได้ทำอะไร)
            currentScreen = isLoggedIn || isGuestMode ? .home : .login
        }
    }
    
    // --- 👇 [เพิ่ม] ฟังก์ชันสำหรับเข้าสู่ Guest Mode ---
    func enterGuestMode() {
        isLoggedIn = false // ไม่ได้ Login
        isGuestMode = true  // เป็น Guest
        currentScreen = .home // ไปหน้า Home
        navigationStack = [.home] // เริ่ม Stack ใหม่ที่ Home
        print("👤 Entering Guest Mode.")
    }
    
    // --- 👇 [เพิ่ม] ฟังก์ชันสำหรับออกจาก Guest Mode (กลับไป Login) ---
    func exitGuestMode() {
        isLoggedIn = false
        isGuestMode = false
        currentScreen = .login
        navigationStack = [.login]
        print("🚪 Exiting Guest Mode.")
    }
    
    // --- 👇 [เพิ่ม] ฟังก์ชันสำหรับบังคับ Login (เมื่อ Guest กดใช้ฟีเจอร์ที่จำกัด) ---
    func requireLogin() {
        guard isGuestMode else { return } // ทำงานเฉพาะตอนเป็น Guest
        print("🔒 Login required. Exiting Guest Mode.")
        exitGuestMode() // กลับไปหน้า Login
    }
}

// MARK: - Screen Enum (เหมือนเดิม ไม่ต้องแก้)
enum MuTeLuScreen: Equatable {
    case home
    case login
    case registration
    case editProfile
    case recommenderForYou
    case recommendation
    case sacredDetail(place: SacredPlace) // Case ที่มีข้อมูลแนบมา (Associated Value)
    case phoneFortune
    case shirtColor
    case carPlate
    case houseNumber
    case tarot
    case mantra
    case seamSi
    case knowledge
    case wishDetail
    case adminLogin
    case admin
    case gameMenu
    case meritPoints
    case offeringGame
    case bookmarks
    case categorySearch
    // Cases ใหม่ที่เพิ่มเข้ามา
    case knowledgeOfferings
    case knowledgeNumbers
    case knowledgeBuddhistPrinciples
    case gameQuiz
    case gameMeditation
    case gameMatching
    
    /// โค้ดที่กำหนดเองสำหรับการเปรียบเทียบ `Equatable`
    static func == (lhs: MuTeLuScreen, rhs: MuTeLuScreen) -> Bool {
        switch (lhs, rhs) {
            // Cases ที่ไม่มี associated value: เปรียบเทียบโดยตรง
        case (.home, .home), (.login, .login), (.registration, .registration),
            (.editProfile, .editProfile), (.recommenderForYou, .recommenderForYou),
            (.recommendation, .recommendation), (.phoneFortune, .phoneFortune),
            (.shirtColor, .shirtColor), (.carPlate, .carPlate), (.houseNumber, .houseNumber),
            (.tarot, .tarot), (.mantra, .mantra), (.seamSi, .seamSi), (.knowledge, .knowledge),
            (.wishDetail, .wishDetail), (.adminLogin, .adminLogin), (.admin, .admin),
            (.gameMenu, .gameMenu), (.meritPoints, .meritPoints), (.offeringGame, .offeringGame),
            (.bookmarks, .bookmarks), (.categorySearch, .categorySearch),
            // เปรียบเทียบ cases ใหม่
            (.knowledgeOfferings, .knowledgeOfferings), (.knowledgeNumbers, .knowledgeNumbers),
            (.knowledgeBuddhistPrinciples, .knowledgeBuddhistPrinciples), (.gameQuiz, .gameQuiz),
            (.gameMeditation, .gameMeditation), (.gameMatching, .gameMatching):
            return true // ถ้า case ตรงกัน ถือว่าเท่ากัน
            
            // Case ที่มี associated value (.sacredDetail): เปรียบเทียบจาก ID ของสถานที่
        case let (.sacredDetail(place1), .sacredDetail(place2)):
            // ถือว่าเป็นหน้าเดียวกัน ถ้า ID ของสถานที่เหมือนกัน
            return place1.id == place2.id
        default:
            return false
        }
    }
}
