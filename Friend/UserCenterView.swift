import SwiftUI

struct UserCenterView: View {
    @StateObject private var model = UserCenterViewModel()
    @State private var showLogin=false
    private let designWidth:CGFloat=750
    private func px(_ r:CGFloat,_ w:CGFloat)->CGFloat{w*r/designWidth}
    var body: some View {
        GeometryReader { proxy in
            let w=proxy.size.width
            ZStack { Image("FriendUserIndex").resizable().scaledToFill().ignoresSafeArea(); Color.black.opacity(0.1).ignoresSafeArea(); ScrollView(showsIndicators:false){ VStack(spacing:0){
                Color.clear.frame(height:proxy.safeAreaInsets.top+px(88,w))
                if let info=model.userInfo { profile(info,width:w); stats(info,width:w); dynamic(info,width:w) } else { Button("请登录"){showLogin=true}.foregroundStyle(.white).padding(.top,100) }
                userCenterList(width:w)
                Color.clear.frame(height:120)
            }.padding(.horizontal,px(32,w)) }.refreshable { await model.refresh() } }
        }.navigationTitle("").navigationBarHidden(true).sheet(isPresented:$showLogin){NavigationView{LoginView()}}.task{await model.loadIfNeeded()}
    }
    private func profile(_ info:PersonalCenter,width w:CGFloat)->some View { HStack(spacing:px(46,w)){RemoteAvatar(urlString:info.headPortrait,size:px(140,w));VStack(alignment:.leading,spacing:0){Text(info.nickName ?? "用户").font(.system(size:px(44,w),weight:.bold)).foregroundStyle(.white);HStack(spacing:px(26,w)){HStack(spacing:4){Image("FriendMoneyIcon").resizable().frame(width:px(20,w),height:px(20,w));Text("余额 \(info.goldBalance ?? 0)").font(.system(size:px(24,w))).foregroundStyle(.white)};Text("IP \(info.city ?? "未知")").font(.system(size:px(28,w))).foregroundStyle(Color(red:0.27,green:0.28,blue:0.36))}.padding(.top,px(24,w))};Spacer()} }
    private func stats(_ info:PersonalCenter,width w:CGFloat)->some View { HStack{NavigationLink(destination:MyDynamicsView()){statistic("\(info.blogCount ?? 0)","动态",w)};NavigationLink(destination:FollowFansView()){statistic("\(info.followCount ?? 0)","关注",w)};NavigationLink(destination:FollowFansView()){statistic("\(info.fansCount ?? 0)","粉丝",w)}}.padding(.top,px(60,w)).padding(.bottom,px(70,w)) }
    private func statistic(_ v:String,_ t:String,_ w:CGFloat)->some View{VStack(spacing:4){Text(v).font(.system(size:px(36,w),weight:.bold)).foregroundStyle(.white);Text(t).font(.system(size:px(32,w))).foregroundStyle(Color(red:0.27,green:0.28,blue:0.36))}.frame(maxWidth:.infinity)}
    private func dynamic(_ info:PersonalCenter,width w:CGFloat)->some View { VStack(alignment:.leading,spacing:12){Text("我的动态").font(.system(size:px(32,w),weight:.bold)).foregroundStyle(.white);HStack(spacing:12){dynamicCard("动态 1",w);dynamicCard("动态 2",w)}}.padding(.bottom,px(50,w)) }
    private func dynamicCard(_ title:String,_ w:CGFloat)->some View { VStack(alignment:.leading,spacing:8){RoundedRectangle(cornerRadius:16).fill(Color.white.opacity(0.12)).frame(height:px(140,w));Text(title).font(.system(size:14)).foregroundStyle(.white.opacity(0.85))}.frame(maxWidth:.infinity) }
    private func userCenterList(width w:CGFloat)->some View { VStack(alignment:.leading,spacing:0){Text("用户中心").font(.system(size:px(32,w),weight:.bold)).foregroundStyle(.white).padding(.bottom,px(40,w));NavigationLink(destination:PrivacyView()){row("FriendUserItemIcon2","隐私设置",w)};NavigationLink(destination:RechargeView()){row("FriendUserItemIcon1","账户充值",w)};Button("退出登录",role:.destructive){Task{await model.logout()}}.padding(.top,22)}.frame(maxWidth:.infinity,alignment:.leading) }
    private func row(_ icon:String,_ title:String,_ w:CGFloat)->some View{HStack{Image(icon).resizable().frame(width:px(46,w),height:px(46,w));Text(title).font(.system(size:px(28,w))).foregroundStyle(.white);Spacer();Image(systemName:"chevron.right").foregroundStyle(.white.opacity(0.7))}.padding(.vertical,px(15,w))}
}
@MainActor final class UserCenterViewModel:ObservableObject{
    @Published var userInfo:PersonalCenter?
    @Published var errorMessage:String?
    private static let cacheKey = "friend.user.center.cache"

    func loadIfNeeded() async {
        guard TokenStore.shared.token != nil else { return }
        if userInfo == nil, let data = UserDefaults.standard.data(forKey: Self.cacheKey), let cached = try? JSONDecoder().decode(PersonalCenter.self, from: data) { userInfo = cached }
        guard userInfo == nil else { return }
        await load(force: true)
    }

    func load(force: Bool = false) async {
        guard TokenStore.shared.token != nil else { return }
        if !force, userInfo != nil { return }
        do { let r:APIEnvelope<PersonalCenter>=try await APIClient.shared.request(path:"community/fruser/personalCenter",method:"GET",body:EmptyBody()); userInfo=r.data; if let info = r.data, let data = try? JSONEncoder().encode(info) { UserDefaults.standard.set(data, forKey: Self.cacheKey) } }
        catch { errorMessage=error.localizedDescription }
    }

    func refresh() async { await load(force: true) }
    func logout() async { _ = try? await APIClient.shared.request(path:"token/logout",method:"DELETE",body:EmptyBody()) as EmptyResponse; TokenStore.shared.clear(); userInfo=nil; UserDefaults.standard.removeObject(forKey: Self.cacheKey) }
}

struct PersonalCenter:Decodable{let headPortrait:String?;let nickName:String?;let goldBalance:Int?;let city:String?;let blogCount:Int?;let followCount:Int?;let fansCount:Int?}
