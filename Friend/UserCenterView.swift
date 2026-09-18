import SwiftUI

struct UserCenterView: View {
    @StateObject private var model = UserCenterViewModel()
    let topSafeArea: CGFloat?
    @State private var showLogin = false
    private let designWidth: CGFloat = 750
    private func px(_ r: CGFloat, _ w: CGFloat) -> CGFloat { w * r / designWidth }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack {
                Image("FriendUserIndex").resizable().scaledToFill().ignoresSafeArea()
                Color.black.opacity(0.1).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: (topSafeArea ?? proxy.safeAreaInsets.top) + px(24, w))
                        topBar(width: w)
                        if let info = model.userInfo {
                            profile(info, width: w)
                            dynamic(info, width: w)
                        } else {
                            Button("请登录") { showLogin = true }
                                .foregroundStyle(.white).padding(.top, 100)
                        }
                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, px(32, w))
                }
                .refreshable { await model.refresh() }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $showLogin) { NavigationView { LoginView() } }
        .task { await model.loadIfNeeded() }
    }

    private func topBar(width w: CGFloat) -> some View {
        HStack {
            HStack(spacing: 0) {
                Button { } label: { ProfileActionIcon(kind: .pencil) }
                    .frame(width: px(38, w), height: px(38, w))
                Spacer()
                HStack(spacing: px(40, w)) {
                    Button { } label: { ProfileActionIcon(kind: .footprints).frame(width: px(38, w), height: px(38, w)) }
                    Button { } label: { ProfileActionIcon(kind: .addPerson).frame(width: px(38, w), height: px(38, w)) }
                    NavigationLink { UserSettingsView() } label: { ProfileActionIcon(kind: .menu).frame(width: px(38, w), height: px(38, w)) }
                }
                .frame(height: px(60, w))
            }
            .font(.system(size: px(32, w), weight: .medium))
            .foregroundStyle(Color(white: 0.96))
            .frame(height: px(60, w))
        }
        .frame(height: px(52, w))
    }

    private func profile(_ info: PersonalCenter, width w: CGFloat) -> some View {
        HStack(spacing: px(24, w)) {
            VStack(alignment: .leading, spacing: px(18, w)) {
                HStack(spacing: px(18, w)) {
                    Text(info.nickName ?? "用户").font(.system(size: px(40, w), weight: .bold)).foregroundStyle(.white)
                    Text(info.genderText).font(.system(size: px(25, w))).foregroundStyle(.pink)
                    Text("IP \(info.city ?? "未知")").font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.65))
                }
                HStack(spacing: px(32, w)) {
                    statValue("\(info.followCount ?? 0)", "关注", w)
                    statValue("\(info.fansCount ?? 0)", "粉丝", w)
                    statValue("\(info.likeCount ?? 0)", "赞", w)
                }
            }
            Spacer(minLength: 0)
            RemoteAvatar(urlString: info.headPortrait, size: px(140, w))
        }
        .padding(.top, px(34, w))
    }

    private func stats(_ info: PersonalCenter, width w: CGFloat) -> some View { EmptyView() }
    private func statValue(_ value: String, _ title: String, _ w: CGFloat) -> some View { VStack(alignment: .leading, spacing: 2) { Text(value).font(.system(size: px(28, w), weight: .bold)).foregroundStyle(.white); Text(title).font(.system(size: px(22, w))).foregroundStyle(.white.opacity(0.62)) } }
    private func dynamic(_ info: PersonalCenter, width w: CGFloat) -> some View { VStack(alignment: .leading, spacing: 12) { HStack { Text("我的动态").font(.system(size: px(32, w), weight: .bold)).foregroundStyle(.white); Spacer(); NavigationLink("查看全部") { MyDynamicsView() }.font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.7)) }; HStack(spacing: 12) { dynamicCard("动态 1", w); dynamicCard("动态 2", w) } }.padding(.top, px(54, w)).padding(.bottom, px(50, w)) }
    private func dynamicCard(_ title: String, _ w: CGFloat) -> some View { VStack(alignment: .leading, spacing: 8) { RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.12)).frame(height: px(140, w)); Text(title).font(.system(size: 14)).foregroundStyle(.white.opacity(0.85)) }.frame(maxWidth: .infinity) }
}

@MainActor final class UserCenterViewModel: ObservableObject {
    @Published var userInfo: PersonalCenter?
    @Published var errorMessage: String?
    private static let cacheKey = "friend.user.center.cache"
    func loadIfNeeded() async { guard TokenStore.shared.token != nil else { return }; if userInfo == nil, let data = UserDefaults.standard.data(forKey: Self.cacheKey), let cached = try? JSONDecoder().decode(PersonalCenter.self, from: data) { userInfo = cached }; guard userInfo == nil else { return }; await load(force: true) }
    func load(force: Bool = false) async { guard TokenStore.shared.token != nil else { return }; if !force, userInfo != nil { return }; do { let r: APIEnvelope<PersonalCenter> = try await APIClient.shared.request(path: "community/fruser/personalCenter", method: "GET", body: EmptyBody()); userInfo = r.data; if let info = r.data, let data = try? JSONEncoder().encode(info) { UserDefaults.standard.set(data, forKey: Self.cacheKey) } } catch { errorMessage = error.localizedDescription } }
    func refresh() async { await load(force: true) }
}

struct PersonalCenter: Codable {
    let id: Int?
    let headPortrait: String?
    let nickName: String?
    let gender: String?
    let goldBalance: Int?
    let city: String?
    let blogCount: Int?
    let followCount: Int?
    let fansCount: Int?
    let likeCount: Int?
    var genderText: String { gender == "WOMAN" || gender == "女" ? "♀" : gender == "MAN" || gender == "男" ? "♂" : "" }
}
