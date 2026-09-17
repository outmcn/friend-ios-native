import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String?
    let info: UserInfo?
}

struct UserInfo: Codable, Identifiable {
    let id: Int?
    let nickName: String?
    let headPortrait: String?
    let phone: String?
    let city: String?
    let gender: String?
}

struct RegisterRequest: Encodable {
    let headPortrait: String?
    let phone: String?
    let nickName: String
    let birthday: String?
    let lat: String?
    let lon: String?
    let city: String?
    let gender: String?
    let verificationCode: String?
    let password: String
    let truePassword: String
    let cityCode: String?
}

struct EmptyBody: Encodable {}
