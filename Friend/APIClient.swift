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
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 40
        session = URLSession(configuration: configuration)
    }

    func request<Response: Decodable, Body: Encodable>(path: String, method: String = "GET", body: Body? = nil, token: String? = TokenStore.shared.token) async throws -> Response {
        var components = URLComponents(url: APIConfig.baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))), resolvingAgainstBaseURL: false)!
        if method == "GET", let body {
            let data = try encoder.encode(body)
            if let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                components.queryItems = object.compactMap { key, value in URLQueryItem(name: key, value: String(describing: value)) }
            }
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token, !token.isEmpty { request.setValue(token, forHTTPHeaderField: "Authorization") }
        if method != "GET", let body { request.httpBody = try encoder.encode(body) }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError(statusCode: nil, message: "无效的服务器响应") }
        let envelopeCode = (try? decoder.decode(APIEnvelope<EmptyResponse>.self, from: data))?.code
        guard (200..<300).contains(http.statusCode), envelopeCode == nil || envelopeCode == 200 else { throw APIError(statusCode: envelopeCode ?? http.statusCode, message: String(data: data, encoding: .utf8) ?? "请求失败") }
        return try decoder.decode(Response.self, from: data)
    }

    func uploadFile(data: Data, filename: String, mimeType: String, token: String? = TokenStore.shared.token) async throws -> APIEnvelope<UploadResult> {
        let url = APIConfig.baseURL.appendingPathComponent("file/upload")
        let boundary = "FriendBoundary-\(UUID().uuidString)"
        var request = URLRequest(url: url); request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token, !token.isEmpty { request.setValue(token, forHTTPHeaderField: "Authorization") }
        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8)); body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".utf8)); body.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8)); body.append(data); body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        let (responseData, response) = try await session.upload(for: request, from: body)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw APIError(statusCode: (response as? HTTPURLResponse)?.statusCode, message: String(data: responseData, encoding: .utf8) ?? "图片上传失败") }
        let result: APIEnvelope<UploadResult> = try decoder.decode(APIEnvelope<UploadResult>.self, from: responseData)
        guard result.code == 200, result.data?.url != nil else { throw APIError(statusCode: result.code, message: result.msg ?? "图片上传失败") }
        return result
    }
}

final class TokenStore {
    static let shared = TokenStore(); private let key = "friend.auth.token"
    var token: String? { get { UserDefaults.standard.string(forKey: key) } set { UserDefaults.standard.set(newValue, forKey: key) } }
    func clear() { token = nil }
}
