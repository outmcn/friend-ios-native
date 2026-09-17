import SwiftUI

struct RemoteAvatar: View {
    let urlString: String?
    var size: CGFloat = 54

    var body: some View {
        Group {
            if let urlString, let url = normalizedURL(urlString) {
                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: fallback
                    case .empty: ProgressView().tint(.white)
                    @unknown default: fallback
                    }
                }
            } else { fallback }
        }
        .frame(width: size, height: size)
        .background(Color.gray.opacity(0.35))
        .clipShape(Circle())
    }

    private var fallback: some View { Image(systemName: "person.fill").resizable().scaledToFit().padding(size * 0.24).foregroundStyle(.white.opacity(0.8)) }

    private func normalizedURL(_ value: String) -> URL? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        if let url = URL(string: raw), url.scheme != nil { return url }
        return URL(string: "https://friend.outmcn.net/" + raw.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
}
