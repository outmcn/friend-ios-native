import Foundation
import SwiftUI

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var posts: [DiscoveryPost] = DiscoveryPost.placeholders
    @Published var isLoading = false
    func load() async { isLoading = true; defer { isLoading = false } }
}

struct DiscoveryPost: Identifiable {
    let id = UUID()
    let name: String
    let text: String
    let imageName: String?
    let likes: Int
    let comments: Int
    static let placeholders = [
        DiscoveryPost(name: "赵风了一", text: "山雨欲来风满楼", imageName: nil, likes: 234, comments: 23),
        DiscoveryPost(name: "赵风了一", text: "山雨欲来风满楼", imageName: nil, likes: 453, comments: 23),
        DiscoveryPost(name: "赵风了一", text: "风渺渺沙兮裂，袅袅兮秋风", imageName: nil, likes: 0, comments: 0)
    ]
}

struct DiscoveryView: View {
    @StateObject private var model = DiscoveryViewModel()
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.03, blue: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) { ForEach(model.posts) { post in postCard(post) } }.padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 90)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await model.load() }
    }
    private var header: some View {
        VStack(spacing: 0) {
            HStack { ForEach(["附近", "关注", "好友"].indices, id: \.self) { i in Button { model.selectedTab = i } label: { Text(["附近", "关注", "好友"][i]).font(.system(size: i == model.selectedTab ? 18 : 16, weight: i == model.selectedTab ? .bold : .regular)).foregroundStyle(i == model.selectedTab ? .white : .white.opacity(0.55)).padding(.horizontal, 12).padding(.vertical, 10).overlay(alignment: .bottom) { if i == model.selectedTab { Color(red: 0.95, green: 0.80, blue: 0.38).frame(height: 2) } } } }; Spacer(); Button("发一条") {}.font(.system(size: 15, weight: .medium)).foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.38)) }.padding(.horizontal, 18).padding(.top, 12).padding(.bottom, 4)
        }
    }
    private func postCard(_ post: DiscoveryPost) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) { Circle().fill(Color.white.opacity(0.22)).frame(width: 40, height: 40).overlay(Image(systemName: "person.fill").foregroundStyle(.white.opacity(0.8))); Text(post.name).font(.system(size: 16, weight: .medium)).foregroundStyle(.white); Spacer() }
            Text(post.text).font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
            RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [Color(red:0.16,green:0.26,blue:0.50),Color(red:0.90,green:0.47,blue:0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 150).overlay(Image(systemName: "photo").font(.system(size: 34)).foregroundStyle(.white.opacity(0.55)))
            HStack(spacing: 24) { Label("\(post.likes)", systemImage: "heart"); Label("\(post.comments)", systemImage: "message") }.font(.system(size: 14)).foregroundStyle(.white.opacity(0.65))
        }.padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
