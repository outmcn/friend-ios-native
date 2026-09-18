import Foundation

struct BlogPageResponse: Decodable, Identifiable {
    let id: Int
    let userId: Int?
    let content: String?
    let images: [String]?
    let headPortrait: String?
    let nickName: String?
    let pushTime: String?
    let fabulous: Int?
    let comment: Int?
    let thumbsUp: Bool?
}
