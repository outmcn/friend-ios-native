import SwiftUI

struct FollowFansView: View {
    let initialTab: Int
    @StateObject private var model = FollowFansViewModel()
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton("关注列表", 0)
                tabButton("粉丝列表", 1)
            }
            .background(Color(.systemBackground))

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.items) { item in row(item) }
                }
            }
            .refreshable { await model.load(tab: tab) }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: tab) { _ in Task { await model.load(tab: tab) } }
        .task { tab = initialTab; await model.load(tab: initialTab) }
    }

    private func tabButton(_ title: String, _ value: Int) -> some View {
        Button { tab = value } label: {
            Text(title)
                .font(.system(size: value == tab ? 16 : 14, weight: value == tab ? .bold : .regular))
                .foregroundStyle(value == tab ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .overlay(alignment: .bottom) {
                    if value == tab { Color.primary.frame(height: 2) }
                }
        }
    }

    private func row(_ item: FollowItem) -> some View {
        HStack(spacing: 12) {
            RemoteAvatar(urlString: item.headPortrait, size: 51)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.nickName ?? "用户").font(.system(size: 16, weight: .medium))
                Text(item.city ?? "").font(.system(size: 14)).foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.38))
            }
            Spacer()
            Button(model.buttonTitle(item)) { Task { await model.action(item) } }
                .frame(width: 80, height: 30)
                .background(Color(red: 0.95, green: 0.80, blue: 0.38))
                .clipShape(Capsule())
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 30)
        .frame(height: 80)
        .overlay(alignment: .bottom) { Color(.systemGray6).frame(height: 1) }
    }
}

@MainActor final class FollowFansViewModel: ObservableObject {
    @Published var items: [FollowItem] = []
    var tab = 0
    func load(tab: Int) async { self.tab = tab; do { let path = tab == 0 ? "community/fruser/follow/page" : "community/fruser/fans/page"; let r: APIEnvelope<PageResult<FollowItem>> = try await APIClient.shared.request(path: path, method: "GET", body: EmptyBody()); items = r.data?.rows ?? [] } catch { items = [] } }
    func buttonTitle(_ i: FollowItem) -> String { switch i.followStatus { case "FOLLOW": return "取消关注"; case "FRIEND": return "取消互关"; case "FANS": return "移除粉丝"; default: return "关注" } }
    func action(_ i: FollowItem) async { let p: String; switch i.followStatus { case "FOLLOW", "FRIEND": p = "community/fruser/cancel/follow/\(i.id)"; case "FANS": p = "community/fruser/remove/fans/\(i.id)"; default: p = "community/fruser/follow/user/\(i.id)" }; _ = try? await APIClient.shared.request(path: p, method: "GET", body: EmptyBody()) as APIEnvelope<EmptyResponse>; await load(tab: tab) }
}

struct FollowItem: Decodable, Identifiable { let id: Int; let headPortrait: String?; let nickName: String?; let city: String?; let followStatus: String? }
struct PageResult<Row: Decodable>: Decodable { let totalCount: Int?; let rows: [Row] }
