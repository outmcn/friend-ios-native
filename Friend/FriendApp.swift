import SwiftUI

@main
struct FriendApp: App {
    @StateObject private var music = BackgroundMusicPlayer.shared
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if TokenStore.shared.token == nil { LoginView() } else { HomeView() }
            }
            .preferredColorScheme(.dark)
            .task { music.start() }
        }
    }
}
