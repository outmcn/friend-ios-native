import SwiftUI

struct UserCenterView: View {
    @StateObject private var model = UserCenterViewModel()
    @State private var showLogin = false
    var body: some View {
        ZStack {
            Image("FriendUserIndex").resizable().scaledToFill().ignoresSafeArea()
            Color.black.opacity(0.12).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    if let info = model.userInfo {
                        HStack(spacing: 14) {
                            RemoteAvatar(urlString: info.headPortrait, size: 72)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(info.nickName ?? "用户").font(.title3.bold()).foregroundStyle(.white)
                                Text("余额  \(info.goldBalance ?? 0)").font(.subheadline).foregroundStyle(.white.opacity(0.9))
                                Text("IP \(info.city ?? "未知")").font(.footnote).foregroundStyle(.white.opacity(0.85))
                            }; Spacer()
                        }.padding().background(.black.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 16))
                        HStack { statistic(String(info.blogCount ?? 0), "动态"); statistic(String(info.followCount ?? 0), "关注"); statistic(String(info.fansCount ?? 0), "粉丝") }.padding().background(.black.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 16))
                    } else { Button("请登录") { showLogin = true }.foregroundStyle(.white) }
                    VStack(spacing: 0) {
                        NavigationLink(destination: FollowFansView()) { row(icon: "FriendUserItemIcon2", title: "关注 / 粉丝") }
                        row(icon: "FriendUserItemIcon1", title: "账户充值")
                        Button("退出登录", role: .destructive) { Task { await model.logout() } }.padding()
                    }.frame(maxWidth: .infinity, alignment: .leading).background(.black.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 16))
                }.padding()
            }
        }.navigationTitle("").navigationBarHidden(true).sheet(isPresented: $showLogin) { NavigationView { LoginView() } }.task { await model.load() }
    }
    private func statistic(_ value: String, _ title: String) -> some View { VStack(spacing: 4) { Text(value).font(.headline).foregroundStyle(.white); Text(title).font(.caption).foregroundStyle(.white.opacity(0.8)) }.frame(maxWidth: .infinity) }
    private func row(icon: String, title: String) -> some View { HStack { Image(icon).resizable().scaledToFit().frame(width: 28, height: 28); Text(title).foregroundStyle(.white); Spacer(); Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.7)) }.padding() }
}

@MainActor final class UserCenterViewModel: ObservableObject {
    @Published var userInfo: PersonalCenter?
    @Published var errorMessage: String?
    func load() async { guard TokenStore.shared.token != nil else { return }; do { let response: APIEnvelope<PersonalCenter> = try await APIClient.shared.request(path: "community/fruser/personalCenter", method: "GET", body: EmptyBody()); userInfo = response.data } catch { errorMessage = error.localizedDescription } }
    func logout() async { _ = try? await APIClient.shared.request(path: "token/logout", method: "DELETE", body: EmptyBody()) as EmptyResponse; TokenStore.shared.clear(); userInfo = nil }
}
struct PersonalCenter: Decodable { let headPortrait: String?; let nickName: String?; let goldBalance: Int?; let city: String?; let blogCount: Int?; let followCount: Int?; let fansCount: Int? }
