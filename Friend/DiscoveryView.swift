import Foundation
import SwiftUI

@MainActor final class DiscoveryViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var posts: [DiscoveryPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    func load() async { isLoading = true; errorMessage = nil; defer { isLoading = false }; do { let path = selectedTab == 0 ? "community/frblog/near/blog/page" : selectedTab == 1 ? "community/frblog/near/blog/page" : "community/frblog/follow/blog/page"; let r: APIEnvelope<PageResult<BlogPageResponse>> = try await APIClient.shared.request(path: path, method: "GET", body: DiscoveryQuery(pageIndex: 1, pageSize: 50)); guard r.code == 200, let rows = r.data?.rows else { throw APIError(statusCode: r.code, message: r.msg ?? "动态加载失败") }; posts = rows.map { DiscoveryPost($0) }; errorMessage = nil } catch { if Self.isCancellation(error) { errorMessage = nil; return }; errorMessage = error.localizedDescription } }
    private static func isCancellation(_ error: Error) -> Bool { if error is CancellationError { return true }; if let urlError = error as? URLError, urlError.code == .cancelled { return true }; let nsError = error as NSError; return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled || error.localizedDescription.lowercased().contains("cancel") }
}
struct DiscoveryQuery: Encodable { let pageIndex: Int; let pageSize: Int }
struct DiscoveryPost: Identifiable { let id: Int; let userId: Int?; let name: String; let text: String; let imageURL: String?; let likes: Int; let comments: Int; let favorites: Int; let pushTime: String?; let following: Bool?; let headPortrait: String?; init(_ blog: BlogPageResponse) { id=blog.id; userId=blog.userId; name=blog.nickName ?? "用户"; text=blog.content ?? ""; imageURL=blog.images?.first; likes=blog.fabulous ?? 0; comments=blog.comment ?? 0; favorites=blog.favorite ?? 0; pushTime=blog.pushTime; following=blog.following; headPortrait=blog.headPortrait } }

struct DiscoveryView: View {
    @StateObject private var model = DiscoveryViewModel(); @State private var showCompose = false; @State private var showOtherProfile: DiscoveryPost?
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.02, green: 0.03, blue: 0.07).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: max(proxy.safeAreaInsets.top, 44))
                    header
                    ScrollView(showsIndicators: false) {
                        if let error = model.errorMessage, !error.isEmpty, error.lowercased().contains("cancel") == false { Text(error).foregroundStyle(.red).padding() }
                        LazyVStack(spacing: 14) {
                            ForEach(model.posts) { post in
                                NavigationLink(destination: detail(for: post)) { postCard(post) }.buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 140)
                    }
                    .refreshable { await model.load() }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCompose) { ComposePostView(onPublished: { Task { await model.load() } }) }
        .sheet(item: $showOtherProfile) { post in NavigationView { OtherUserProfileView(userId: post.userId ?? 0, seedName: post.name, seedAvatar: post.headPortrait) } }
        .task { await model.load() }

        .onChange(of: model.selectedTab) { _ in Task { await model.load() } }
    }
    private func detail(for post: DiscoveryPost) -> DynamicDetailView {
        DynamicDetailView(blog: BlogPageResponse(id: post.id, userId: post.userId, content: post.text, images: post.imageURL.map { [$0] }, headPortrait: post.headPortrait, nickName: post.name, pushTime: post.pushTime, fabulous: post.likes, comment: post.comments, thumbsUp: nil, favorite: post.favorites, favorited: nil, following: post.following))
    }
    private var header: some View { VStack(spacing:0){ HStack{ForEach(["推荐","附近","关注"].indices,id:\.self){i in Button{model.selectedTab=i}label:{Text(["推荐","附近","关注"][i]).font(.system(size:i==model.selectedTab ? 18:16,weight:i==model.selectedTab ? .bold:.regular)).foregroundStyle(i==model.selectedTab ? .white:.white.opacity(0.55)).padding(.horizontal,12).padding(.vertical,10).overlay(alignment:.bottom){if i==model.selectedTab{Color(red:0.95,green:0.80,blue:0.38).frame(height:2)}}}};Spacer();Button("发一条"){showCompose=true}.font(.system(size:15,weight:.medium)).foregroundStyle(Color(red:0.95,green:0.80,blue:0.38)).padding(.horizontal,12).padding(.vertical,7).overlay(Capsule().stroke(Color(red:0.95,green:0.80,blue:0.38),lineWidth:1.5))}.padding(.horizontal,18).padding(.top,12).padding(.bottom,4)} }
    private func postCard(_ post:DiscoveryPost)->some View { VStack(alignment:.leading,spacing:12){ HStack(spacing:10){Button { if post.userId != currentUserId { showOtherProfile = post } } label: { HStack(spacing:10){RemoteAvatar(urlString:post.headPortrait,size:40);VStack(alignment:.leading,spacing:3){Text(post.name).font(.system(size:16,weight:.medium)).foregroundStyle(.white);Text(post.pushTime ?? "").font(.caption).foregroundStyle(.white.opacity(0.55))}} }.buttonStyle(.plain);Spacer() }; if !post.text.isEmpty{Text(post.text).font(.system(size:17,weight:.medium)).foregroundStyle(.white)};if let url=post.imageURL{DynamicImageView(urlString:url)}else{DynamicImagePlaceholder()};HStack(spacing:24){Label("\(post.likes)",systemImage:"heart");Label("\(post.comments)",systemImage:"message");Label("\(post.favorites)",systemImage:"star")}.font(.system(size:14)).foregroundStyle(.white.opacity(0.65))}.padding(14).background(Color.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius:16)) }
    private var currentUserId: Int? { guard let data=UserDefaults.standard.data(forKey:"friend.user.center.cache"),let p=try? JSONDecoder().decode(PersonalCenter.self,from:data) else{return nil};return p.id }
}
