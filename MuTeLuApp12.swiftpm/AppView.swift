import SwiftUI

struct AppView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var memberStore: MemberStore
    @AppStorage("loggedInEmail") private var loggedInEmail = ""
    @EnvironmentObject var likeStore: LikeStore
    @EnvironmentObject var userActionStore: UserActionStore 
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var activityStore: ActivityStore
    @EnvironmentObject var sacredPlaceViewModel: SacredPlaceViewModel
    
    private var activeMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        Group {
            switch flowManager.currentScreen {
            case .login: LoginView()
            case .registration: RegistrationView()
            case .home: HomeView()
            case .editProfile:
                if let memberToEdit = activeMember { EditProfileView(user: memberToEdit) } else { LoginView() }
            case .recommenderForYou: RecommenderForYouView()
            case .recommendation: RecommendationView()
            case .sacredDetail(let place): SacredPlaceDetailView(place: place)
            case .phoneFortune: PhoneFortuneView()
            case .shirtColor: ShirtColorView()
            case .carPlate: CarPlateView()
            case .houseNumber: HouseNumberView()
            case .tarot: TarotView()
            case .mantra: MantraView()
            case .seamSi: SeamSiView()
            case .knowledge: KnowledgeMenuView()
            case .wishDetail: WishDetailView()
            case .knowledgeOfferings, .knowledgeNumbers, .knowledgeBuddhistPrinciples: ComingSoonView()
            case .adminLogin: AdminLoginView()
            case .admin: AdminView()
            case .gameMenu: GameMenuView()
            case .meritPoints: MeritPointsView()
            case .offeringGame: OfferingGameView()
            case .gameQuiz, .gameMeditation, .gameMatching: ComingSoonView()
            case .bookmarks: BookmarkView()
            case .categorySearch: NavigationStack { CategorySearchView() }
                
            @unknown default:
                Text("Coming soon...")
            }
        }
        .environmentObject(flowManager)
        .environmentObject(language)
        .environmentObject(locationManager)
        .environmentObject(memberStore)
        .environmentObject(activityStore)
        .environmentObject(likeStore)
        .environmentObject(bookmarkStore)
        .environmentObject(userActionStore)
        .environmentObject(sacredPlaceViewModel)
    }
}

#Preview {
    let mockFlowManager = MuTeLuFlowManager()
    let mockLanguage = AppLanguage()
    let mockLocationManager = LocationManager()
    let mockMemberStore = MemberStore()
    let mockActivityStore = ActivityStore()
    let mockLikeStore = LikeStore()
    let mockBookmarkStore = BookmarkStore()
    let mockUserActionStore = UserActionStore() 
    let mockSacredPlaceViewModel = SacredPlaceViewModel()
    
    return AppView()
        .environmentObject(mockFlowManager)
        .environmentObject(mockLanguage)
        .environmentObject(mockLocationManager)
        .environmentObject(mockMemberStore)
        .environmentObject(mockActivityStore)
        .environmentObject(mockLikeStore)
        .environmentObject(mockBookmarkStore)
        .environmentObject(mockUserActionStore)
        .environmentObject(mockSacredPlaceViewModel)
}
