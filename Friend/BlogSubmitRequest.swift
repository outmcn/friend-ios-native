import Foundation
struct BlogSubmitRequest: Encodable { let content: String?; let images: [String]?; let lon: String?; let lat: String?; let city: String? }
