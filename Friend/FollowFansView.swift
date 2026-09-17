import SwiftUI

struct FollowFansView: View {
    @StateObject private var model = FollowFansViewModel()
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $tab) { Text("关注列表").tag(0); Text("粉丝列表").tag(1) }
                .pickerStyle(.segmented).padding()
            List { ForEach(model.items) { item in
                HStack(spacing: 12) {
                    RemoteAvatar(urlString: item.headPortrait, size: 51)
                    VStack(alignment: .leading, spacing: 5) { Text(item.nickName ?? "用户"); Text(item.city ?? "").font(.footnote).foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.38)) }
                    Spacer()
                    Button(model.buttonTitle(item)) { Task { await model.action(item) } }
                        .buttonStyle(.borderedProminent).tint(Color(red: 0.95, green: 0.80, blue: 0.38)).foregroundStyle(.black)
                }
            } }
            .listStyle(.plain)
            .refreshable { await model.load(tab: tab) }
        }
        .navigationTitle(tab == 0 ? "关注列表" : "粉丝列表")
        .onChange(of: tab) { _ in Task { await model.load(tab: tab) } }
        .task { await model.load(tab: tab) }
    }
}

@MainActor
final class FollowFansViewModel: ObservableObject {
    @Published var items: [FollowItem] = []
    @Published var tab = 0

    func load(tab: Int) async {
        self.tab = tab
        do {
            let path = tab == 0 ? "community/fruser/follow/page" : "community/fruser/fans/page"
            let response: APIEnvelope<PageResult<FollowItem>> = try await APIClient.shared.request(path: path, method: "GET", body: EmptyBody())
            items = response.data?.rows ?? []
        } catch { items = [] }
    }

    func buttonTitle(_ item: FollowItem) -> String {
        switch item.followStatus {
        case "FOLLOW": return "取消关注"
        case "FRIEND": return "取消互关"
        case "FANS": return "移除粉丝"
        default: return "关注"
        }
    }

    func action(_ item: FollowItem) async {
        let path: String
        switch item.followStatus {
        case "FOLLOW", "FRIEND": path = "community/fruser/cancel/follow/\(item.id)"
        case "FANS": path = "community/fruser/remove/fans/\(item.id)"
        default: path = "community/fruser/follow/user/\(item.id)"
        }
        _ = try? await APIClient.shared.request(path: path, method: "GET", body: EmptyBody()) as APIEnvelope<EmptyResponse>
        await load(tab: tab)
    }
}

struct FollowItem: Decodable, Identifiable {
    let id: Int
    let headPortrait: String?
    let nickName: String?
    let city: String?
    let followStatus: String?
}

struct PageResult<Row: Decodable>: Decodable {
    let totalCount: Int?
    let rows: [Row]
}
