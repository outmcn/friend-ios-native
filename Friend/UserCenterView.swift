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
    private func dynamic(_ info: PersonalCenter, width w: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("我的动态").font(.system(size: px(32, w), weight: .bold)).foregroundStyle(.white)
                Spacer()
                if !(info.blog ?? []).isEmpty { NavigationLink("查看全部") { MyDynamicsView() }.font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.7)) }
            }
            if let blogs = info.blog, !blogs.isEmpty {
                HStack(spacing: 12) {
                    ForEach(blogs.prefix(2)) { blog in dynamicCard(blog, w) }
                }
            } else {
                Text("暂无动态").font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.6)).frame(maxWidth: .infinity, minHeight: px(100, w))
            }
        }.padding(.top, px(54, w)).padding(.bottom, px(50, w))
    }
    private func dynamicCard(_ blog: PersonalCenterBlog, _ w: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = blog.image, !image.isEmpty { RemoteAvatar(urlString: image, size: px(140, w)) }
            Text(blog.content ?? "").font(.system(size: 14)).foregroundStyle(.white.opacity(0.85)).lineLimit(2)
            Text(blog.time ?? "").font(.system(size: 12)).foregroundStyle(.white.opacity(0.55))
        }.padding(10).frame(maxWidth: .infinity, minHeight: px(140, w), alignment: .topLeading).background(Color.white.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

@MainActor final class UserCenterViewModel: ObservableObject {
    @Published var userInfo: PersonalCenter?
    @Published var errorMessage: String?
    private static let cacheKey = "friend.user.center.cache"
    func loadIfNeeded() async { guard TokenStore.shared.token != nil else { return }; if userInfo == nil, let data = UserDefaults.standard.data(forKey: Self.cacheKey), let cached = try? JSONDecoder().decode(PersonalCenter.self, from: data) { userInfo = cached }; guard userInfo == nil else { return }; await load(force: true) }
    func load(force: Bool = false) async { guard TokenStore.shared.token != nil else { return }; if !force, userInfo != nil { return }; do { let r: APIEnvelope<PersonalCenter> = try await APIClient.shared.request(path: "community/fruser/personalCenter", method: "GET", body: EmptyBody()); userInfo = r.data; if let info = r.data, let data = try? JSONEncoder().encode(info) { UserDefaults.standard.set(data, forKey: Self.cacheKey) } } catch { errorMessage = error.localizedDescription } }
    func refresh() async { await load(force: true) }
}

struct PersonalCenterBlog: Codable, Identifiable {
    let image: String?
    let content: String?
    let time: String?
    private let idValue: Int
    var id: Int { idValue }
    enum CodingKeys: String, CodingKey { case id, image, content, time }
    init(id: Int?, image: String?, content: String?, time: String?) { self.image = image; self.content = content; self.time = time; self.idValue = id ?? content?.hashValue ?? 0 }
    init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); let id = try c.decodeIfPresent(Int.self, forKey: .id); self.image = try c.decodeIfPresent(String.self, forKey: .image); self.content = try c.decodeIfPresent(String.self, forKey: .content); self.time = try c.decodeIfPresent(String.self, forKey: .time); self.idValue = id ?? content?.hashValue ?? 0 }
    func encode(to encoder: Encoder) throws { var c = encoder.container(keyedBy: CodingKeys.self); try c.encode(idValue, forKey: .id); try c.encodeIfPresent(image, forKey: .image); try c.encodeIfPresent(content, forKey: .content); try c.encodeIfPresent(time, forKey: .time) }
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
    let blog: [PersonalCenterBlog]?
    var genderText: String { gender == "WOMAN" || gender == "女" ? "♀" : gender == "MAN" || gender == "男" ? "♂" : "" }
}
