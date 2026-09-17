import Foundation

struct MatchingConfig: Encodable {
    let type: String
    let userId: Int
}

struct TUICallCredentials: Decodable {
    let sdkAppId: Int?
    let userId: String?
    let userSig: String?
    let nickName: String?
    let avatar: String?
}

struct MatchInfo: Decodable {
    let id: Int?
    let headPortraitSelf: String?
    let headPortrait: String?
    let nickName: String?
    let message: String?
}

final class MatchingService: NSObject, URLSessionWebSocketDelegate {
    private var socket: URLSessionWebSocketTask?
    private var heartbeat: Task<Void, Never>?
    private let session: URLSession
    private(set) var matchingType = "ORDINARY"

    override init() {
        session = URLSession(configuration: .default)
        super.init()
    }

    func start(type: String, userId: Int) async throws {
        matchingType = type
        var request = URLRequest(url: APIConfig.webSocketURL)
        request.setValue(TokenStore.shared.token, forHTTPHeaderField: "Authorization")
        socket = session.webSocketTask(with: request)
        socket?.resume()
        try await sendText("{\"messageType\":\"CONNECT\",\"info\":\"" + String(userId) + "\"}")
        heartbeat = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self else { continue }
                let payload = #"{"messageType":"MATCHING","info":"{'type':'"# + self.matchingType + #"','userId':"# + String(userId) + #"}"}"#
                try? await self.sendText(payload)
            }
        }
    }

    func receive() async throws -> MatchInfo {
        guard let socket else { throw APIError(statusCode: nil, message: "匹配连接未建立") }
        let message = try await socket.receive()
        switch message {
        case .string(let text): return try JSONDecoder().decode(MatchInfo.self, from: Data(text.utf8))
        case .data(let data): return try JSONDecoder().decode(MatchInfo.self, from: data)
        @unknown default: throw APIError(statusCode: nil, message: "未知匹配消息")
        }
    }

    func stop() async {
        heartbeat?.cancel(); heartbeat = nil
        socket?.cancel(with: .goingAway, reason: nil); socket = nil
        _ = try? await APIClient.shared.request(path: "community/fruser/end/matching", method: "GET", body: EmptyBody()) as APIEnvelope<EmptyResponse>
    }

    private func sendText(_ text: String) async throws {
        guard let socket else { throw APIError(statusCode: nil, message: "匹配连接未建立") }
        try await socket.send(.string(text))
    }
}
