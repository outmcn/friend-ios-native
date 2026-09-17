import Foundation

struct APIConfig {
    static let baseURL = URL(string: "https://friend.outmcn.net/api/msfastcommunity")!
    static let webSocketURL = URL(string: "wss://friend.outmcn.net/ws")!
}

struct APIError: Error, LocalizedError {
    let statusCode: Int?
    let message: String
    var errorDescription: String? { message }
}

final class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 40
        session = URLSession(configuration: configuration)
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }

    func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String = "GET",
        body: Body? = nil,
        token: String? = TokenStore.shared.token
    ) async throws -> Response {
        let url = APIConfig.baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token, !token.isEmpty { request.setValue(token, forHTTPHeaderField: "Authorization") }
        if let body { request.httpBody = try encoder.encode(body) }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError(statusCode: nil, message: "无效的服务器响应") }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError(statusCode: http.statusCode, message: String(data: data, encoding: .utf8) ?? "请求失败")
        }
        return try decoder.decode(Response.self, from: data)
    }
}

final class TokenStore {
    static let shared = TokenStore()
    private let key = "friend.auth.token"
    var token: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    func clear() { token = nil }
}
