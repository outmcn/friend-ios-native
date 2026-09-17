import SwiftUI

@main
struct FriendApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if TokenStore.shared.token == nil {
                    LoginView()
                } else {
                    HomeView()
                }
            }
        }
    }
}
