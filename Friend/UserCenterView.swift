import SwiftUI

struct UserCenterView: View {
    @StateObject private var model = UserCenterViewModel()
    @State private var showLogin = false
    private let designWidth: CGFloat = 750
    private func px(_ rpx: CGFloat, _ width: CGFloat) -> CGFloat { width * rpx / designWidth }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("FriendUserIndex").resizable().scaledToFill().ignoresSafeArea()
                Color.black.opacity(0.12).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if let info = model.userInfo {
                            HStack(spacing: px(46, proxy.size.width)) {
                                RemoteAvatar(urlString: info.headPortrait, size: px(176, proxy.size.width))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(info.nickName ?? "用户").font(.system(size: px(44, proxy.size.width), weight: .bold)).foregroundStyle(.white)
                                    HStack(spacing: px(26, proxy.size.width)) {
                                        HStack(spacing: 4) { Image("FriendMoneyIcon").resizable().frame(width: px(20, proxy.size.width), height: px(20, proxy.size.width)); Text("余额 \(info.goldBalance ?? 0)").font(.system(size: px(24, proxy.size.width))).foregroundStyle(.white) }
                                        Text("IP \(info.city ?? "未知")").font(.system(size: px(28, proxy.size.width))).foregroundStyle(Color(red: 0.27, green: 0.28, blue: 0.36))
                                    }.padding(.top, px(24, proxy.size.width))
                                }
                                Spacer()
                            }
                            HStack {
                                statistic(String(info.blogCount ?? 0), "动态", width: proxy.size.width)
                                statistic(String(info.followCount ?? 0), "关注", width: proxy.size.width)
                                statistic(String(info.fansCount ?? 0), "粉丝", width: proxy.size.width)
                            }.padding(.top, px(60, proxy.size.width))
                        } else {
                            Button("请登录") { showLogin = true }.foregroundStyle(.white)
                        }
                        VStack(spacing: 0) {
                            row(icon: "FriendUserItemIcon2", title: "关注 / 粉丝", width: proxy.size.width)
                            row(icon: "FriendUserItemIcon1", title: "账户充值", width: proxy.size.width)
                            Button("退出登录", role: .destructive) { Task { await model.logout() } }.padding()
                        }.frame(maxWidth: .infinity, alignment: .leading).background(.black.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, px(32, proxy.size.width))
                    .padding(.top, px(88, proxy.size.width))
                    .padding(.bottom, px(160, proxy.size.width))
                }
            }
        }
        .navigationTitle("").navigationBarHidden(true)
        .sheet(isPresented: $showLogin) { NavigationView { LoginView() } }
        .task { await model.load() }
    }

    private func statistic(_ value: String, _ title: String, width: CGFloat) -> some View {
        VStack(spacing: 4) { Text(value).font(.system(size: px(36, width), weight: .bold)).foregroundStyle(.white); Text(title).font(.system(size: px(32, width))).foregroundStyle(Color(red: 0.27, green: 0.28, blue: 0.36)) }.frame(maxWidth: .infinity)
    }
    private func row(icon: String, title: String, width: CGFloat) -> some View { HStack { Image(icon).resizable().scaledToFit().frame(width: px(46, width), height: px(46, width)); Text(title).font(.system(size: px(28, width))).foregroundStyle(Color(red: 0.85, green: 0.85, blue: 0.85)); Spacer(); Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.7)) }.padding(.vertical, px(15, width)).padding(.horizontal, px(16, width)) }
}

@MainActor final class UserCenterViewModel: ObservableObject {
    @Published var userInfo: PersonalCenter?
    @Published var errorMessage: String?
    func load() async { guard TokenStore.shared.token != nil else { return }; do { let response: APIEnvelope<PersonalCenter> = try await APIClient.shared.request(path: "community/fruser/personalCenter", method: "GET", body: EmptyBody()); userInfo = response.data } catch { errorMessage = error.localizedDescription } }
    func logout() async { _ = try? await APIClient.shared.request(path: "token/logout", method: "DELETE", body: EmptyBody()) as EmptyResponse; TokenStore.shared.clear(); userInfo = nil }
}
struct PersonalCenter: Decodable { let headPortrait: String?; let nickName: String?; let goldBalance: Int?; let city: String?; let blogCount: Int?; let followCount: Int?; let fansCount: Int? }
