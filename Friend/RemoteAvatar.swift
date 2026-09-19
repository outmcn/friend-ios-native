import SwiftUI
import UIKit

struct FriendHomeBackground: View {
    var body: some View { Color(red: 0.01, green: 0.04, blue: 0.07).ignoresSafeArea() }
}

struct RemoteAvatar: View {
    let urlString: String?
    var size: CGFloat = 54
    @State private var image: UIImage?
    var body: some View {
        Group { if let local = ZodiacAsset.image(for: urlString) { Image(uiImage: local).resizable().interpolation(.none).scaledToFill() } else if let urlString, let url = normalizedURL(urlString) { AsyncImage(url: url) { phase in switch phase { case .success(let image): image.resizable().scaledToFill(); case .failure: fallback; case .empty: ProgressView().tint(.white); @unknown default: fallback } } } else { fallback } }.frame(width: size, height: size).background(Color.gray.opacity(0.35)).clipShape(Circle())
    }
    private var fallback: some View { Image(systemName: "person.fill").resizable().scaledToFit().padding(size * 0.24).foregroundStyle(.white.opacity(0.8)) }
    private func normalizedURL(_ value: String) -> URL? { let raw=value.trimmingCharacters(in:.whitespacesAndNewlines); guard !raw.isEmpty,raw.count<2048 else{return nil}; if let u=URL(string:raw),let scheme=u.scheme?.lowercased(),scheme=="http"||scheme=="https"{if u.host=="127.0.0.1"||u.host=="localhost"{return URL(string: "https://friend.outmcn.net"+u.path)};return u}; return URL(string:"https://friend.outmcn.net/"+raw.trimmingCharacters(in:CharacterSet(charactersIn:"/"))) }
}
