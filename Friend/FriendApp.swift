import SwiftUI

@main
struct FriendApp: App {
    @StateObject private var music = BackgroundMusicPlayer.shared
    @StateObject private var location = LocationRefreshService.shared
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if TokenStore.shared.token == nil { LoginView() } else { HomeView() }
            }
            .preferredColorScheme(.dark)
            .task { music.start(); location.refreshIfNeeded() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in location.refreshIfNeeded() }
        }
    }
}
