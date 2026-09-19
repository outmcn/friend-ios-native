import Foundation

struct ProfileUpdate: Codable {
    let id: Int
    let nickName: String
    let headPortrait: String
}

extension Notification.Name {
    static let profileUpdated = Notification.Name("friend.profile.updated")
}
