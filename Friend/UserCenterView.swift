import SwiftUI

struct UserCenterView: View {
    @StateObject private var model = UserCenterViewModel()
    @StateObject private var dynamics = UserCenterDynamicsViewModel()
    @State private var showLogin = false
    @State private var cachedCity: String?
    @State private var showProfileEditor = false
    @State private var showAvatarActions = false
    @State private var selectedDynamicsCategory = 0
    let topSafeArea: CGFloat?
    private let designWidth: CGFloat = 750
    private func px(_ r: CGFloat, _ w: CGFloat) -> CGFloat { w * r / designWidth }
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack {
                Image("FriendUserIndex").resizable().scaledToFill().ignoresSafeArea()
                Color.black.opacity(0.1).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: (topSafeArea ?? proxy.safeAreaInsets.top) + px(24, w))
                    topBar(width: w)
                    if let info = model.userInfo {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                                profile(info, width: w)
                                Section {
                                    if dynamics.items.isEmpty {
                                        if let error = dynamics.errorMessage { Text(error).font(.system(size: px(24, w))).foregroundStyle(.red) }
                                        else { Text("暂无动态").font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.6)) }
                                    } else {
                                        ForEach(dynamics.items) { blog in blogCard(blog, w) }
                                    }
                                } header: {
                                    dynamicsCategories(width: w)
                                        .padding(.top, px(12, w))
                                }
                            }
                            .padding(.horizontal, px(32, w))
                            .padding(.bottom, 120)
                        }
                        .refreshable { await refreshAll() }
                    } else if TokenStore.shared.token == nil {
                        Button("请登录") { showLogin = true }.foregroundStyle(.white).padding(.top, 100)
                        Spacer()
                    } else {
                        DiscoveryLoadingPlaceholder().padding(.top, 36)
                        Spacer()
                    }
                }
            }
        }.navigationTitle("").navigationBarHidden(true).sheet(isPresented: $showLogin) { NavigationView { LoginView() } }.sheet(isPresented: $showProfileEditor) { if let info = model.userInfo { ProfileEditorSheet(info: info, onSaved: applyProfileUpdate) } }.sheet(isPresented: $showAvatarActions) { if let info = model.userInfo { AvatarActionSheet(info: info) } }.task { cachedCity = LocationRefreshService.shared.cachedCity; await loadAll() }.onReceive(NotificationCenter.default.publisher(for: .profileUpdated)) { note in if let updated = note.object as? ProfileUpdate, var current = model.userInfo { current = PersonalCenter(id: current.id, headPortrait: updated.headPortrait, nickName: updated.nickName, gender: current.gender, goldBalance: current.goldBalance, city: current.city, blogCount: current.blogCount, followCount: current.followCount, fansCount: current.fansCount, likeCount: current.likeCount, blog: current.blog); model.userInfo = current; if let data = try? JSONEncoder().encode(current) { UserDefaults.standard.set(data, forKey: "friend.user.center.cache") } } }.onReceive(NotificationCenter.default.publisher(for: .locationCityUpdated)) { note in cachedCity = note.object as? String }
    }
    private func applyProfileUpdate(_ updated: ProfileUpdate) { guard let current = model.userInfo else { return }; let next = PersonalCenter(id: current.id, headPortrait: updated.headPortrait, nickName: updated.nickName, gender: current.gender, goldBalance: current.goldBalance, city: current.city, blogCount: current.blogCount, followCount: current.followCount, fansCount: current.fansCount, likeCount: current.likeCount, blog: current.blog); model.userInfo = next; if let data = try? JSONEncoder().encode(next) { UserDefaults.standard.set(data, forKey: "friend.user.center.cache") } }
 await model.loadIfNeeded(); dynamics.loadIfNeeded(); Task { do { try await dynamics.load() } catch { dynamics.errorMessage = error.localizedDescription } } }
    private func refreshAll() async { await model.refresh(); do { try await dynamics.load() } catch { dynamics.errorMessage = error.localizedDescription } }
    private func topBar(width w: CGFloat) -> some View { HStack { Spacer() }.frame(height: px(52, w)) }
    private func profile(_ info: PersonalCenter, width w: CGFloat) -> some View {
        HStack(spacing: px(24, w)) {
            VStack(alignment: .leading, spacing: px(18, w)) {
                HStack(spacing: px(18, w)) {
                    Text(info.nickName ?? "用户").font(.system(size: px(40, w), weight: .bold)).foregroundStyle(.white)
                    Button("编辑") { showProfileEditor = true }.font(.system(size: px(22, w), weight: .medium)).foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.38))
                    Text(info.genderText).font(.system(size: px(25, w))).foregroundStyle(.pink)
                    Text("IP \((info.city ?? cachedCity ?? "未知").replacingOccurrences(of: "市", with: ""))").font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.65))
                }
                HStack(spacing: px(32, w)) {
                    statValue("\(info.followCount ?? 0)", "关注", w)
                    statValue("\(info.fansCount ?? 0)", "粉丝", w)
                    statValue("\(info.likeCount ?? 0)", "获赞", w)
                }
            }
            Spacer(minLength: 0)
            Button { showAvatarActions = true } label: { RemoteAvatar(urlString: info.headPortrait, size: px(140, w)) }.buttonStyle(.plain)
        }
        .padding(.horizontal, px(28, w))
        .padding(.vertical, px(26, w))
        .background(Color.black.opacity(0.38))
        .overlay(RoundedRectangle(cornerRadius: px(24, w)).stroke(Color.white.opacity(0.16), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: px(24, w)))
        .shadow(color: .black.opacity(0.25), radius: px(16, w), y: px(8, w))
        .padding(.top, px(22, w))
    }
    private func statValue(_ value: String, _ title: String, _ w: CGFloat) -> some View { VStack(alignment: .leading, spacing: 2) { Text(value).font(.system(size: px(28, w), weight: .bold)).foregroundStyle(.white); Text(title).font(.system(size: px(22, w))).foregroundStyle(.white.opacity(0.62)) } }
    private func dynamicList(width w: CGFloat) -> some View { VStack(alignment: .leading, spacing: 12) { dynamicsCategories(width: w); if dynamics.items.isEmpty { if let error=dynamics.errorMessage { Text(error).font(.system(size: px(24, w))).foregroundStyle(.red) } else { Text("暂无动态").font(.system(size: px(24, w))).foregroundStyle(.white.opacity(0.6)) } } else { ForEach(dynamics.items) { blogCard($0, w) } } }.padding(.top, px(54, w)).padding(.bottom, px(50, w)) }
    private func dynamicsCategories(width w: CGFloat) -> some View { HStack(spacing: 0) { ForEach(["动态", "锁定", "收藏", "点赞"].indices, id: \.self) { i in Button { selectedDynamicsCategory = i } label: { Text(["动态", "锁定", "收藏", "点赞"][i]).font(.system(size: px(24, w), weight: i == selectedDynamicsCategory ? .bold : .regular)).foregroundStyle(i == selectedDynamicsCategory ? .white : .white.opacity(0.55)).frame(maxWidth: .infinity).padding(.vertical, px(18, w)).overlay(alignment: .bottom) { if i == selectedDynamicsCategory { Color(red: 0.95, green: 0.80, blue: 0.38).frame(height: 2) } } } } }.padding(.horizontal, px(10, w)).background(Color.black.opacity(0.18)).clipShape(RoundedRectangle(cornerRadius: px(12, w))).overlay(RoundedRectangle(cornerRadius: px(12, w)).stroke(Color.white.opacity(0.12), lineWidth: 1)) }
    private func blogCard(_ blog: BlogPageResponse, _ w: CGFloat) -> some View { NavigationLink { DynamicDetailView(blog: blog) } label: { VStack(alignment: .leading, spacing: 10) { HStack { Text(blog.pushTime ?? "").font(.caption).foregroundStyle(.white.opacity(0.6)); Spacer() }; if let content = blog.content, !content.isEmpty { Text(content).font(.system(size: 16)).foregroundStyle(.white) }; if let images = blog.images { ForEach(images, id: \.self) { image in DynamicImageView(urlString: image) } }; HStack { Label("\(blog.fabulous ?? 0)", systemImage: "heart"); Label("\(blog.comment ?? 0)", systemImage: "message") }.font(.footnote).foregroundStyle(.white.opacity(0.75)) }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(Color.white.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 16)) }.buttonStyle(.plain) }
}

@MainActor final class UserCenterDynamicsViewModel: ObservableObject {
    @Published var items: [BlogPageResponse] = []
    @Published var errorMessage: String?
    @Published var likeError: String?
    private let cacheKey = "friend.user.dynamics.cache"
    init() { if let data = UserDefaults.standard.data(forKey: cacheKey), let cached = try? JSONDecoder().decode([BlogPageResponse].self, from: data) { items = cached } }
    func loadIfNeeded() { guard items.isEmpty else { return } }
    func load() async throws { let r: APIEnvelope<PageResult<BlogPageResponse>> = try await APIClient.shared.request(path: "community/frblog/mine/blog/page", method: "GET", body: UserCenterPageQuery(pageIndex: 1, pageSize: 100)); guard r.code == 200, let rows = r.data?.rows else { throw APIError(statusCode: r.code, message: r.msg ?? "动态数据为空") }; items = rows; UserDefaults.standard.removeObject(forKey: cacheKey); if let data = try? JSONEncoder().encode(rows) { UserDefaults.standard.set(data, forKey: cacheKey) }; errorMessage = nil }
    func toggleLike(_ item: BlogPageResponse) async throws { let r: APIEnvelope<EmptyResponse> = try await APIClient.shared.request(path: "community/frblog/like/\(item.id)", method: "POST", body: EmptyBody()); guard r.code == 200 else { throw APIError(statusCode: r.code, message: r.msg ?? "点赞失败") }; try await load() }
}
struct UserCenterPageQuery: Encodable { let pageIndex: Int; let pageSize: Int }
@MainActor final class UserCenterViewModel: ObservableObject { @Published var userInfo: PersonalCenter?; @Published var errorMessage: String?; private static let cacheKey = "friend.user.center.cache"; func loadIfNeeded() async { guard TokenStore.shared.token != nil else { return }; if userInfo == nil, let data = UserDefaults.standard.data(forKey: Self.cacheKey), let cached = try? JSONDecoder().decode(PersonalCenter.self, from: data) { userInfo = cached }; guard userInfo == nil else { return }; await load(force: true) }; func load(force: Bool = false) async { guard TokenStore.shared.token != nil else { return }; if !force, userInfo != nil { return }; do { let r: APIEnvelope<PersonalCenter> = try await APIClient.shared.request(path: "community/fruser/personalCenter", method: "GET", body: EmptyBody()); guard let info = r.data else { throw APIError(statusCode: r.code, message: r.msg ?? "个人资料为空") }; userInfo = info; if let data = try? JSONEncoder().encode(info) { UserDefaults.standard.set(data, forKey: Self.cacheKey) } } catch { errorMessage = error.localizedDescription } }; func refresh() async { await load(force: true) } }
struct PersonalCenterBlog: Codable, Identifiable { let image: String?; let content: String?; let time: String?; private let idValue: Int; var id: Int { idValue }; enum CodingKeys: String, CodingKey { case id, image, content, time }; init(from decoder: Decoder) throws { let c = try decoder.container(keyedBy: CodingKeys.self); let id = try c.decodeIfPresent(Int.self, forKey: .id); image = try c.decodeIfPresent(String.self, forKey: .image); content = try c.decodeIfPresent(String.self, forKey: .content); time = try c.decodeIfPresent(String.self, forKey: .time); idValue = id ?? content?.hashValue ?? 0 }; func encode(to encoder: Encoder) throws { var c = encoder.container(keyedBy: CodingKeys.self); try c.encode(idValue, forKey: .id); try c.encodeIfPresent(image, forKey: .image); try c.encodeIfPresent(content, forKey: .content); try c.encodeIfPresent(time, forKey: .time) } }
struct PersonalCenter: Codable { let id: Int?; let headPortrait: String?; let nickName: String?; let gender: String?; let goldBalance: Int?; let city: String?; let blogCount: Int?; let followCount: Int?; let fansCount: Int?; let likeCount: Int?; let blog: [PersonalCenterBlog]?; var genderText: String { gender == "WOMAN" || gender == "女" ? "♀" : gender == "MAN" || gender == "男" ? "♂" : "" } }
