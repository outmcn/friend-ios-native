import Foundation
import SwiftUI

struct OtherUserProfileView: View {
    let userId: Int
    let seedName: String
    let seedAvatar: String?
    @StateObject private var model: OtherUserProfileModel
    init(userId: Int, seedName: String, seedAvatar: String?) { self.userId = userId; self.seedName = seedName; self.seedAvatar = seedAvatar; _model = StateObject(wrappedValue: OtherUserProfileModel(userId: userId, seedName: seedName, seedAvatar: seedAvatar)) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    RemoteAvatar(urlString: model.info?.headPortrait ?? seedAvatar, size: 76)
                    VStack(alignment: .leading, spacing: 6) { Text(model.info?.nickName ?? seedName).font(.title3.bold()).foregroundStyle(.white); Text(model.info?.city ?? "").font(.caption).foregroundStyle(.white.opacity(0.6)) }
                    Spacer()
                    if let status = model.info?.followStatus, status != "FRIEND" { Button(status == "FOLLOW" ? "已关注" : "关注") { Task { await model.toggleFollow() } }.buttonStyle(.borderedProminent) }
                }.padding()
                HStack { stat("\(model.info?.blogCount ?? Int64(model.posts.count))", "动态"); Spacer(); stat("\(model.info?.followCount ?? 0)", "关注"); Spacer(); stat("\(model.info?.fansCount ?? 0)", "粉丝") }.padding(.horizontal)
                if let message = model.message { Text(message).foregroundStyle(.red).padding() }
                ForEach(model.posts) { post in NavigationLink { DynamicDetailView(blog: post) } label: { VStack(alignment: .leading, spacing: 8) { Text(post.content ?? "").foregroundStyle(.white); Text(post.pushTime ?? "").font(.caption).foregroundStyle(.white.opacity(0.55)); HStack { Label("\(post.fabulous ?? 0)", systemImage: "heart"); Label("\(post.comment ?? 0)", systemImage: "message") }.font(.caption).foregroundStyle(.white.opacity(0.7)) }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(Color.white.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14)) }.buttonStyle(.plain) }.padding(.horizontal)
            }
        }.background(Color(red: 0.02, green: 0.03, blue: 0.07).ignoresSafeArea()).navigationTitle("个人主页").task { await model.load() }
    }
    private func stat(_ value: String, _ title: String) -> some View { VStack { Text(value).bold(); Text(title).font(.caption).foregroundStyle(.secondary) } }
}

@MainActor final class OtherUserProfileModel: ObservableObject {
    let userId: Int; let seedName: String; let seedAvatar: String?
    @Published var info: OtherUserInfo?
    @Published var posts: [BlogPageResponse] = []
    @Published var message: String?
    @Published var followCount: Int64 = 0
    @Published var fansCount: Int64 = 0
    init(userId: Int, seedName: String, seedAvatar: String?) { self.userId = userId; self.seedName = seedName; self.seedAvatar = seedAvatar }
    func load() async {
        do {
            let user: APIEnvelope<OtherUserInfo> = try await APIClient.shared.request(path: "community/fruser/user/info/\(userId)", method: "GET", body: EmptyBody())
            guard user.code == 200, let data = user.data else { throw APIError(statusCode: user.code, message: user.msg ?? "用户资料加载失败") }
            info = data
            followCount = data.followCount ?? 0
            fansCount = data.fansCount ?? 0
            let feed: APIEnvelope<PageResult<BlogPageResponse>> = try await APIClient.shared.request(path: "community/frblog/friend/blog/page/\(userId)", method: "GET", body: DiscoveryQuery(pageIndex: 1, pageSize: 50))
            guard feed.code == 200 else { throw APIError(statusCode: feed.code, message: feed.msg ?? "动态加载失败") }
            posts = feed.data?.rows ?? []; message = nil
        } catch { message = error.localizedDescription }
    }
    func toggleFollow() async {
        let path = info?.followStatus == "FOLLOW" || info?.followStatus == "FRIEND" ? "community/fruser/cancel/follow/\(userId)" : "community/fruser/follow/user/\(userId)"
        do { let response: APIEnvelope<String> = try await APIClient.shared.request(path: path, method: "GET", body: EmptyBody()); guard response.code == 200 else { throw APIError(statusCode: response.code, message: response.msg ?? "关注失败") }; await load() } catch { message = error.localizedDescription }
    }
}
struct OtherUserInfo: Decodable { let id: Int?; let headPortrait: String?; let nickName: String?; let city: String?; let followStatus: String?; let blogCount: Int64?; let followCount: Int64?; let fansCount: Int64? }
