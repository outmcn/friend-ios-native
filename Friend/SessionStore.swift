import Foundation
import SwiftUI

@MainActor final class SessionStore: ObservableObject {
    static let shared = SessionStore()
    @Published private(set) var isAuthenticated = TokenStore.shared.token != nil
    private init() {}
    func setAuthenticated(_ value: Bool) { isAuthenticated = value }
    func logout() { TokenStore.shared.clear(); UserDefaults.standard.removeObject(forKey: "friend.user.center.cache"); isAuthenticated = false }
}
