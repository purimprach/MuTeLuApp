import Foundation

// MARK: - Flow Manager (ตัวจัดการการเปลี่ยนหน้า)
class MuTeLuFlowManager: ObservableObject {
    @Published var currentScreen: MuTeLuScreen = .home // หน้าจอปัจจุบันที่แสดง
    @Published var isLoggedIn: Bool = false // สถานะการล็อกอิน
    @Published var members: [Member] = [] // ข้อมูลสมาชิก (อาจไม่จำเป็นต้องเก็บที่นี่)
    @Published var loggedInEmail: String = "" // อีเมลของผู้ใช้ที่ล็อกอินอยู่
    
    // เก็บประวัติหน้าจอที่ผู้ใช้เข้าไป (Stack)
    @Published var navigationStack: [MuTeLuScreen] = [.home] // เริ่มต้นด้วยหน้า home
    
    /// ฟังก์ชันสำหรับเปลี่ยนไปหน้าจอใหม่ และเพิ่มลงในประวัติ (stack)
    /// - Parameter screen: หน้าจอ `MuTeLuScreen` ที่ต้องการไป
    func navigateTo(_ screen: MuTeLuScreen) {
        // ป้องกันการเพิ่มหน้าจอเดิมซ้ำซ้อน ถ้าหน้าสุดท้ายใน stack ไม่ใช่หน้าที่จะไป
        if navigationStack.last != screen {
            navigationStack.append(screen) // เพิ่มหน้าใหม่ลง stack
        }
        currentScreen = screen // อัปเดตหน้าจอปัจจุบันที่แสดงผล
    }
    
    /// ฟังก์ชันสำหรับย้อนกลับไปยังหน้าจอก่อนหน้าในประวัติ (stack)
    func navigateBack() {
        // ตรวจสอบว่ามีหน้าจอให้ย้อนกลับหรือไม่ (ต้องมีมากกว่า 1 หน้าใน stack)
        if navigationStack.count > 1 {
            navigationStack.removeLast() // ลบหน้าจอปัจจุบันออกจาก stack
            // ตั้งค่าหน้าจอปัจจุบันให้เป็นหน้าสุดท้ายที่เหลืออยู่ใน stack
            // ถ้า stack ว่างเปล่า (ซึ่งไม่ควรเกิดถ้าเริ่มที่ home) ให้กลับไป home
            currentScreen = navigationStack.last ?? .home
        } else {
            // ถ้าใน stack เหลือแค่หน้า home ให้คงอยู่ที่หน้า home
            currentScreen = .home
        }
    }
}

// MARK: - Screen Enum (ประเภทของหน้าจอทั้งหมดในแอป)
/// กำหนดประเภทของหน้าจอทั้งหมดที่เป็นไปได้ในแอป MuTeLu
/// ทำให้เป็น `Equatable` เพื่อให้สามารถเปรียบเทียบหน้าจอได้ (จำเป็นสำหรับ navigation stack)
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
            // **สำคัญ:** ต้องมั่นใจว่า struct SacredPlace ของคุณ conform Hashable หรือมี id ที่เปรียบเทียบได้
            return place1.id == place2.id
            
            // กรณีอื่นๆ ทั้งหมด: ถือว่าไม่เท่ากัน
        default:
            return false
        }
    }
}

