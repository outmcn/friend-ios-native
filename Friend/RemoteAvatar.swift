import SwiftUI
import UIKit

struct AnimatedHomeBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.animationImages = loadFrames()
        view.animationDuration = 13.5
        view.animationRepeatCount = 0
        view.startAnimating()
        return view
    }
    func updateUIView(_ uiView: UIImageView, context: Context) {}
    private func loadFrames() -> [UIImage] {
        guard let url = Bundle.main.url(forResource: "home", withExtension: "gif"), let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return [] }
        return (0..<CGImageSourceGetCount(source)).compactMap { UIImage(cgImage: CGImageSourceCreateImageAtIndex(source, $0, nil)!) }
    }
}

struct FriendHomeBackground: View {
    var body: some View { AnimatedHomeBackground().ignoresSafeArea() }
}

struct RemoteAvatar: View {
    let urlString: String?
    var size: CGFloat = 54
    var body: some View {
        Group {
            if let urlString, let url = normalizedURL(urlString) {
                AsyncImage(url: url) { phase in
                    switch phase { case .success(let image): image.resizable().scaledToFill(); case .failure: fallback; case .empty: ProgressView().tint(.white); @unknown default: fallback }
                }
            } else { fallback }
        }.frame(width: size, height: size).background(Color.gray.opacity(0.35)).clipShape(Circle())
    }
    private var fallback: some View { Image(systemName: "person.fill").resizable().scaledToFit().padding(size * 0.24).foregroundStyle(.white.opacity(0.8)) }
    private func normalizedURL(_ value: String) -> URL? { let raw=value.trimmingCharacters(in:.whitespacesAndNewlines); guard !raw.isEmpty,raw.count<2048 else{return nil}; if let u=URL(string:raw),let s=u.scheme?.lowercased(),s=="http"||s=="https"{return u}; return URL(string:"https://friend.outmcn.net/"+raw.trimmingCharacters(in:CharacterSet(charactersIn:"/"))) }
}
