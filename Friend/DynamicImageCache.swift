import SwiftUI
import UIKit

final class DynamicImageCache {
    static let shared = DynamicImageCache()
    private let memory = NSCache<NSURL, UIImage>()
    private let queue = DispatchQueue(label: "friend.dynamic.image.cache", attributes: .concurrent)
    private let directory: URL
    private init() { directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("friend-dynamic-images", isDirectory: true); try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true) }
    func image(for url: URL) -> UIImage? { if let image = memory.object(forKey: url as NSURL) { return image }; let file = directory.appendingPathComponent(url.absoluteString.data(using: .utf8)!.base64EncodedString().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "+", with: "-")); guard let data = try? Data(contentsOf: file), let image = UIImage(data: data) else { return nil }; memory.setObject(image, forKey: url as NSURL); return image }
    func save(_ data: Data, for url: URL) -> UIImage? { guard let image = UIImage(data: data) else { return nil }; memory.setObject(image, forKey: url as NSURL); let name = url.absoluteString.data(using: .utf8)!.base64EncodedString().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "+", with: "-"); try? data.write(to: directory.appendingPathComponent(name), options: .atomic); return image }
}

struct DynamicImagePlaceholder: View { var body: some View { RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [Color(red:0.16,green:0.26,blue:0.50),Color(red:0.90,green:0.47,blue:0.28)],startPoint:.topLeading,endPoint:.bottomTrailing)).frame(height:150).overlay(Image(systemName:"photo").font(.system(size:34)).foregroundStyle(.white.opacity(0.55))) } }

struct DynamicImageView: View {
    let urlString: String
    @State private var image: UIImage?
    @State private var loading = false
    var body: some View { Group { if let image { Image(uiImage:image).resizable().scaledToFit() } else { DynamicImagePlaceholder() } }.frame(maxWidth:.infinity).background(Color.black.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius:12)).task { await load() } }
    private func load() async { guard !loading, let url=imageURL else{return}; if let cached=DynamicImageCache.shared.image(for:url){image=cached;return}; loading=true; defer{loading=false}; do{let (data,response)=try await URLSession.shared.data(from:url); guard (response as? HTTPURLResponse)?.statusCode == 200 else{return}; if let saved=DynamicImageCache.shared.save(data,for:url){image=saved}}catch{} }
    private var imageURL: URL? { let raw=urlString.trimmingCharacters(in:.whitespacesAndNewlines); guard !raw.isEmpty else{return nil}; if let url=URL(string:raw),let scheme=url.scheme?.lowercased(),scheme=="http"||scheme=="https"{if url.host=="127.0.0.1"||url.host=="localhost"{return URL(string:"https://friend.outmcn.net\(url.path)")};return url};return URL(string:"https://friend.outmcn.net/"+raw.trimmingCharacters(in:CharacterSet(charactersIn:"/"))) }
}
