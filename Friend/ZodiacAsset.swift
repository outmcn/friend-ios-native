import UIKit

enum ZodiacAsset {
    static func image(for id: String?) -> UIImage? {
        guard let id, id.count > 0 else { return nil }
        let key = id.hasPrefix("zodiac_") ? id : "zodiac_\(id)"
        return UIImage(named: key)
    }
}
