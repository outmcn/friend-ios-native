import SwiftUI

@main
struct FriendApp: App {
    @StateObject private var music = BackgroundMusicPlayer.shared
    @StateObject private var location = LocationRefreshService.shared
    @StateObject private var session = SessionStore.shared
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if session.isAuthenticated { HomeView() } else { LoginView() }
            }
            .preferredColorScheme(.dark)
            .task { music.start(); location.refreshIfNeeded() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in location.refreshIfNeeded() }
        }
    }
}
