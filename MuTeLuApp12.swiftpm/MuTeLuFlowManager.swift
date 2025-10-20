import Foundation

class MuTeLuFlowManager: ObservableObject {
    @Published var currentScreen: MuTeLuScreen = .login
    @Published var isLoggedIn: Bool = false
    @Published var isGuestMode: Bool = false
    @Published var navigationStack: [MuTeLuScreen] = [.login]
    @Published var showLoginPromptAlert: Bool = false
    
    // ... (navigateTo, navigateBack เหมือนเดิม) ...
    func navigateTo(_ screen: MuTeLuScreen) {
        if navigationStack.last != screen {
            navigationStack.append(screen)
        }
        currentScreen = screen
        if screen != .login && screen != .registration && screen != .home {
            // isGuestMode = false // <--- ลอง comment บรรทัดนี้ไว้ก่อน
        }
    }
    func navigateBack() {
        if navigationStack.count > 1 {
            navigationStack.removeLast()
            currentScreen = navigationStack.last ?? (isLoggedIn || isGuestMode ? .home : .login)
        } else {
            currentScreen = isLoggedIn || isGuestMode ? .home : .login
        }
    }
    
    // ... (enterGuestMode, exitGuestMode เหมือนเดิม) ...
    func enterGuestMode() {
        isLoggedIn = false
        isGuestMode = true
        currentScreen = .home
        navigationStack = [.home]
        print("👤 Entering Guest Mode.")
    }
    func exitGuestMode() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.isGuestMode = false
            self.currentScreen = .login
            self.navigationStack = [.login]
            print("🚪 Exiting Guest Mode on Main Thread.")
        }
    }
    
    
    // --- 👇 [แก้ไข] ฟังก์ชัน requireLogin ---
    func requireLogin() {
        guard isGuestMode else { return } // ทำงานเฉพาะตอนเป็น Guest
        print("🔒 Login required prompt triggered.")
        showLoginPromptAlert = true 
    }
}

enum MuTeLuScreen: Equatable {
    case home
    case login
    case registration
    case editProfile
    case recommenderForYou
    case recommendation
    case sacredDetail(place: SacredPlace)
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
    case knowledgeOfferings
    case knowledgeNumbers
    case knowledgeBuddhistPrinciples
    case gameQuiz
    case gameMeditation
    case gameMatching
    
    static func == (lhs: MuTeLuScreen, rhs: MuTeLuScreen) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home), (.login, .login), (.registration, .registration),
            (.editProfile, .editProfile), (.recommenderForYou, .recommenderForYou),
            (.recommendation, .recommendation), (.phoneFortune, .phoneFortune),
            (.shirtColor, .shirtColor), (.carPlate, .carPlate), (.houseNumber, .houseNumber),
            (.tarot, .tarot), (.mantra, .mantra), (.seamSi, .seamSi), (.knowledge, .knowledge),
            (.wishDetail, .wishDetail), (.adminLogin, .adminLogin), (.admin, .admin),
            (.gameMenu, .gameMenu), (.meritPoints, .meritPoints), (.offeringGame, .offeringGame),
            (.bookmarks, .bookmarks), (.categorySearch, .categorySearch),
            (.knowledgeOfferings, .knowledgeOfferings), (.knowledgeNumbers, .knowledgeNumbers),
            (.knowledgeBuddhistPrinciples, .knowledgeBuddhistPrinciples), (.gameQuiz, .gameQuiz),
            (.gameMeditation, .gameMeditation), (.gameMatching, .gameMatching):
            return true
        case let (.sacredDetail(place1), .sacredDetail(place2)):
            return place1.id == place2.id
        default:
            return false
        }
    }
}
