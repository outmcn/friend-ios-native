import SwiftUI

struct UserCenterView: View {
    @StateObject private var model = UserCenterViewModel()
    @State private var showLogin = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    if let info = model.userInfo {
                        HStack(spacing: 14) {
                            AsyncImage(url: URL(string: info.headPortrait ?? "")) { image in image.resizable().scaledToFill() } placeholder: { Color.gray }
                                .frame(width: 72, height: 72).clipShape(Circle())
                            VStack(alignment: .leading, spacing: 6) {
                                Text(info.nickName ?? "用户").font(.title3.bold())
                                Text("余额  \(info.goldBalance ?? 0)").font(.subheadline).foregroundStyle(.secondary)
                                Text("IP \(info.city ?? "未知")").font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        HStack {
                            statistic(String(info.blogCount ?? 0), "动态")
                            statistic(String(info.followCount ?? 0), "关注")
                            statistic(String(info.fansCount ?? 0), "粉丝")
                        }
                        .padding().background(.background).clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Button("请登录") { showLogin = true }
                    }
                    VStack(spacing: 0) {
                        NavigationLink("关注 / 粉丝", destination: FollowFansView())
                            .padding()
                        if model.userInfo != nil {
                            Button("退出登录", role: .destructive) { Task { await model.logout() } }.padding()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background).clipShape(RoundedRectangle(cornerRadius: 16))
                }.padding()
            }
        }
        .navigationTitle("我的")
        .sheet(isPresented: $showLogin) { NavigationView { LoginView() } }
        .task { await model.load() }
    }

    private func statistic(_ value: String, _ title: String) -> some View {
        VStack(spacing: 4) { Text(value).font(.headline); Text(title).font(.caption).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity)
    }
}

@MainActor
final class UserCenterViewModel: ObservableObject {
    @Published var userInfo: PersonalCenter?
    @Published var errorMessage: String?

    func load() async {
        guard TokenStore.shared.token != nil else { return }
        do {
            let response: APIEnvelope<PersonalCenter> = try await APIClient.shared.request(path: "community/fruser/personalCenter", method: "GET", body: EmptyBody())
            userInfo = response.data
        } catch { errorMessage = error.localizedDescription }
    }

    func logout() async {
        _ = try? await APIClient.shared.request(path: "token/logout", method: "DELETE", body: EmptyBody()) as EmptyResponse
        TokenStore.shared.clear(); userInfo = nil
    }
}

struct PersonalCenter: Decodable {
    let headPortrait: String?
    let nickName: String?
    let goldBalance: Int?
    let city: String?
    let blogCount: Int?
    let followCount: Int?
    let fansCount: Int?
}
