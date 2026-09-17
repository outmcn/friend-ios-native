import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: UserInfo?

    var isLoggedIn: Bool { TokenStore.shared.token != nil }

    func login() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "请输入账号和密码"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let response: LoginResponse = try await APIClient.shared.request(
                path: "token/login", method: "POST",
                body: LoginRequest(username: username, password: password), token: nil
            )
            guard let token = response.token, !token.isEmpty else { throw APIError(statusCode: nil, message: "登录响应缺少 Token") }
            TokenStore.shared.token = token
            user = response.info
        } catch { errorMessage = error.localizedDescription }
    }

    func logout() async {
        _ = try? await APIClient.shared.request(path: "token/logout", method: "POST", body: EmptyBody()) as EmptyResponse
        TokenStore.shared.clear()
        user = nil
    }
}

struct EmptyResponse: Decodable {}
