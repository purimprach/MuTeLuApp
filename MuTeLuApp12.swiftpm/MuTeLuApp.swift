import SwiftUI

@main
struct MuTeLuApp: App {
    @StateObject var language = AppLanguage()
    @StateObject var flowManager = MuTeLuFlowManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var memberStore = MemberStore()
    @StateObject var likeStore = LikeStore()
    @StateObject var bookmarkStore = BookmarkStore()
    @StateObject var activityStore = ActivityStore()
    @StateObject var userActionStore = UserActionStore()
    @StateObject var sacredPlaceViewModel = SacredPlaceViewModel()
    @StateObject var notificationStore = NotificationStore()
    
    var body: some Scene {
        WindowGroup {
            RootWrapperView()
                .environmentObject(language)
                .environmentObject(flowManager)
                .environmentObject(locationManager)
                .environmentObject(memberStore)
                .environmentObject(likeStore)
                .environmentObject(bookmarkStore)
                .environmentObject(activityStore)
                .environmentObject(userActionStore)
                .environmentObject(sacredPlaceViewModel)
                .environmentObject(notificationStore)
        }
    }
}
