import Foundation

struct APIEnvelope<Value: Decodable>: Decodable {
    let code: Int?
    let msg: String?
    let data: Value?
}

struct DiscoveryUser: Decodable, Identifiable {
    let id: Int?
    let headPortrait: String?
    let nickName: String?
}

struct PageRows<T: Decodable>: Decodable {
    let totalCount: Int?
    let rows: [T]?
}

struct FollowUser: Decodable, Identifiable {
    let id: Int
    let headPortrait: String?
    let nickName: String?
    let city: String?
    let followStatus: String?
}
