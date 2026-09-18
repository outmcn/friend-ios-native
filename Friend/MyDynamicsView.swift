import SwiftUI

struct MyDynamicsView: View {
    @StateObject private var model = MyDynamicsViewModel()
    var body: some View {
        ZStack { Color(.systemGroupedBackground).ignoresSafeArea(); ScrollView { LazyVStack(spacing: 14) { ForEach(model.items) { item in blogCard(item) } }.padding() } }
        .navigationTitle("我的动态").navigationBarTitleDisplayMode(.inline)
        .task { await model.load() }.refreshable { await model.load() }
    }
    private func blogCard(_ item: BlogPageResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { RemoteAvatar(urlString: item.headPortrait, size: 42); VStack(alignment: .leading) { Text(item.nickName ?? "管理员").font(.headline); Text(item.pushTime ?? "").font(.caption).foregroundStyle(.secondary) }; Spacer(); Menu { Button("删除动态", role: .destructive) { Task { await model.delete(item) } } } label: { Image(systemName: "ellipsis") } }
            if let content = item.content, !content.isEmpty { Text(content).font(.body) }
            if let images = item.images, !images.isEmpty { ForEach(images, id: \.self) { image in RemoteAvatar(urlString: image, size: 180) } }
            HStack { Button { Task { await model.toggleLike(item) } } label: { Label("\(item.fabulous ?? 0)", systemImage: item.thumbsUp == true ? "heart.fill" : "heart") }; NavigationLink { CommentsView(blogId: item.id) } label: { Label("\(item.comment ?? 0)", systemImage: "message") } }.font(.footnote).foregroundStyle(.secondary)
        }.padding().background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct CommentsView: View {
    let blogId: Int
    @StateObject private var model = CommentsViewModel()
    @State private var content = ""
    var body: some View { VStack { List(model.items) { c in VStack(alignment: .leading) { Text(c.nickName ?? "用户").font(.headline); Text(c.content ?? ""); Text(c.pushTime ?? "").font(.caption).foregroundStyle(.secondary) } }; HStack { TextField("写评论", text: $content).textFieldStyle(.roundedBorder); Button("发送") { Task { await model.submit(blogId: blogId, content: content); content = "" } } }.padding() }.navigationTitle("评论").navigationBarTitleDisplayMode(.inline).task { await model.load(blogId: blogId) } }
}

struct CommentItem: Decodable, Identifiable { let id: Int; let userId: Int?; let content: String?; let nickName: String?; let pushTime: String? }
@MainActor final class CommentsViewModel: ObservableObject {
    @Published var items: [CommentItem] = []
    func load(blogId: Int) async { do { let r: APIEnvelope<PageResult<CommentItem>> = try await APIClient.shared.request(path: "community/frblog/blog/comment/page/\(blogId)", method: "GET", body: CommentsQuery(pageIndex: 1, pageSize: 100)); items = r.data?.rows ?? [] } catch { items = [] } }
    func submit(blogId: Int, content: String) async { guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }; _ = try? await APIClient.shared.request(path: "community/frblog/blog/comment/\(blogId)", method: "POST", body: CommentRequest(content: content)) as APIEnvelope<EmptyResponse>; await load(blogId: blogId) }
}
struct CommentsQuery: Encodable { let pageIndex: Int; let pageSize: Int }
struct CommentRequest: Encodable { let content: String }
