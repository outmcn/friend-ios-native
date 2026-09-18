import SwiftUI

struct MyDynamicsView: View {
    @StateObject private var model = MyDynamicsViewModel()
    var body: some View {
        ZStack { Color(.systemGroupedBackground).ignoresSafeArea(); ScrollView { LazyVStack(spacing: 14) { ForEach(model.items) { item in NavigationLink { DynamicDetailView(blog: item) } label: { blogCard(item) }.buttonStyle(.plain) } }.padding() } }
        .navigationTitle("我的动态").navigationBarTitleDisplayMode(.inline)
        .task { await model.load() }.refreshable { await model.load() }
    }
    private func blogCard(_ item: BlogPageResponse) -> some View { VStack(alignment: .leading, spacing: 10) { HStack { RemoteAvatar(urlString: item.headPortrait, size: 42); VStack(alignment: .leading) { Text(item.nickName ?? "管理员").font(.headline); Text(item.pushTime ?? "").font(.caption).foregroundStyle(.secondary) }; Spacer() }; if let content=item.content,!content.isEmpty { Text(content).font(.body) }; if let images=item.images,!images.isEmpty { ForEach(images,id:\.self){ RemoteAvatar(urlString:$0,size:180) } }; HStack { Label("\(item.fabulous ?? 0)",systemImage:"heart"); Label("\(item.comment ?? 0)",systemImage:"message") }.font(.footnote).foregroundStyle(.secondary) }.padding().background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius:14)) }
}

struct DynamicDetailView: View {
    let blog: BlogPageResponse
    @StateObject private var model = DynamicDetailViewModel()
    var body: some View { VStack(spacing:0) { ScrollView { VStack(alignment:.leading,spacing:14) { HStack { RemoteAvatar(urlString:blog.headPortrait,size:48); VStack(alignment:.leading){Text(blog.nickName ?? "用户").font(.headline);Text(blog.pushTime ?? "").font(.caption).foregroundStyle(.secondary)};Spacer(); if blog.userId == model.currentUserId { Menu { Button("删除动态",role:.destructive){Task{await model.delete(blog)}} } label:{Image(systemName:"ellipsis")} } }; if let content=blog.content,!content.isEmpty{Text(content).font(.body)}; if let images=blog.images,!images.isEmpty{ForEach(images,id:\.self){RemoteAvatar(urlString:$0,size:260)}}; HStack { Button{Task{await model.toggleLike(blog)}}label:{Label("\(model.likeCount)",systemImage:model.liked ? "heart.fill":"heart")}; Spacer() }.foregroundStyle(.secondary); Divider(); Text("评论").font(.headline); ForEach(model.comments){c in VStack(alignment:.leading,spacing:4){Text(c.nickName ?? "用户").font(.subheadline.bold());Text(c.content ?? "");Text(c.pushTime ?? "").font(.caption).foregroundStyle(.secondary)}.frame(maxWidth:.infinity,alignment:.leading)} }.padding() }; HStack{TextField("写评论",text:$model.commentText).textFieldStyle(.roundedBorder);Button("发送"){Task{await model.submit(blogId:blog.id)}}}.padding() }.navigationTitle("动态详情").navigationBarTitleDisplayMode(.inline).task{await model.load(blog:blog)} }
}

@MainActor final class DynamicDetailViewModel: ObservableObject {
    @Published var comments:[CommentItem]=[]; @Published var commentText=""; @Published var liked=false; @Published var likeCount=0; var currentUserId:Int? { nil }
    func load(blog:BlogPageResponse) async { likeCount=blog.fabulous ?? 0; liked=blog.thumbsUp ?? false; do { let r:APIEnvelope<PageResult<CommentItem>>=try await APIClient.shared.request(path:"community/frblog/blog/comment/page/\(blog.id)",method:"GET",body:CommentsQuery(pageIndex:1,pageSize:100));comments=r.data?.rows ?? [] } catch {} }
    func toggleLike(_ blog:BlogPageResponse) async { let _:APIEnvelope<EmptyResponse>?=try? await APIClient.shared.request(path:"community/frblog/like/\(blog.id)",method:"POST",body:EmptyBody()); await load(blog:blog) }
    func submit(blogId:Int) async { let text=commentText.trimmingCharacters(in:.whitespacesAndNewlines); guard !text.isEmpty else{return}; let _:APIEnvelope<EmptyResponse>?=try? await APIClient.shared.request(path:"community/frblog/blog/comment/\(blogId)",method:"POST",body:CommentRequest(content:text));commentText=""; do{let r:APIEnvelope<PageResult<CommentItem>>=try await APIClient.shared.request(path:"community/frblog/blog/comment/page/\(blogId)",method:"GET",body:CommentsQuery(pageIndex:1,pageSize:100));comments=r.data?.rows ?? []}catch{} }
    func delete(_ blog:BlogPageResponse) async { let _:APIEnvelope<EmptyResponse>?=try? await APIClient.shared.request(path:"community/frblog/\(blog.id)",method:"DELETE",body:EmptyBody()) }
}

@MainActor final class MyDynamicsViewModel: ObservableObject { @Published var items:[BlogPageResponse]=[]; func load() async { do{let r:APIEnvelope<PageResult<BlogPageResponse>>=try await APIClient.shared.request(path:"community/frblog/mine/blog/page",method:"GET",body:MyDynamicsPageQuery(pageIndex:1,pageSize:20));items=r.data?.rows ?? []}catch{items=[]} } }
struct MyDynamicsPageQuery:Encodable{let pageIndex:Int;let pageSize:Int}
struct CommentItem:Decodable,Identifiable{let id:Int;let userId:Int?;let content:String?;let nickName:String?;let pushTime:String?}
struct CommentsQuery:Encodable{let pageIndex:Int;let pageSize:Int}
struct CommentRequest:Encodable{let content:String}
