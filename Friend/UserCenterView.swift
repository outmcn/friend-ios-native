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
                if let info=model.userInfo { VStack(spacing:0) { profile(info,width:w); stats(info,width:w) }.padding(.horizontal,px(22,w)).padding(.vertical,px(22,w)).background(Image("tabbarBackground").resizable().scaledToFill().clipped()).clipShape(RoundedRectangle(cornerRadius:px(28,w))).overlay(RoundedRectangle(cornerRadius:px(28,w)).stroke(Color.white.opacity(0.22),lineWidth:1)); dynamic(info,width:w) } else { Button("请登录"){showLogin=true}.foregroundStyle(.white).padding(.top,100) }
                userCenterList(width:w)
                Color.clear.frame(height:120)
            }.padding(.horizontal,px(32,w)) } }
        }.navigationTitle("").navigationBarHidden(true).sheet(isPresented:$showLogin){NavigationView{LoginView()}}.task{await model.load()}
    }
    private func profile(_ info:PersonalCenter,width w:CGFloat)->some View { HStack(spacing:px(46,w)){RemoteAvatar(urlString:info.headPortrait,size:px(176,w));VStack(alignment:.leading,spacing:0){Text(info.nickName ?? "用户").font(.system(size:px(44,w),weight:.bold)).foregroundStyle(.white);HStack(spacing:px(26,w)){HStack(spacing:4){Image("FriendMoneyIcon").resizable().frame(width:px(20,w),height:px(20,w));Text("余额 \(info.goldBalance ?? 0)").font(.system(size:px(24,w))).foregroundStyle(.white)};Text("IP \(info.city ?? "未知")").font(.system(size:px(28,w))).foregroundStyle(Color(red:0.27,green:0.28,blue:0.36))}.padding(.top,px(24,w))};Spacer()} }
    private func stats(_ info:PersonalCenter,width w:CGFloat)->some View { HStack{statistic("\(info.blogCount ?? 0)","动态",w);statistic("\(info.followCount ?? 0)","关注",w);statistic("\(info.fansCount ?? 0)","粉丝",w)}.padding(.top,px(60,w)).padding(.bottom,px(70,w)) }
    private func statistic(_ v:String,_ t:String,_ w:CGFloat)->some View{VStack(spacing:4){Text(v).font(.system(size:px(36,w),weight:.bold)).foregroundStyle(.white);Text(t).font(.system(size:px(32,w))).foregroundStyle(Color(red:0.27,green:0.28,blue:0.36))}.frame(maxWidth:.infinity)}
    private func dynamic(_ info:PersonalCenter,width w:CGFloat)->some View { EmptyView() }
    private func userCenterList(width w:CGFloat)->some View { VStack(alignment:.leading,spacing:0){Text("用户中心").font(.system(size:px(32,w),weight:.bold)).foregroundStyle(.white).padding(.bottom,px(40,w));row("FriendUserItemIcon2","关注 / 粉丝",w);row("FriendUserItemIcon1","账户充值",w);Button("退出登录",role:.destructive){Task{await model.logout()}}.padding(.top,22)}.frame(maxWidth:.infinity,alignment:.leading) }
    private func row(_ icon:String,_ title:String,_ w:CGFloat)->some View{HStack{Image(icon).resizable().frame(width:px(46,w),height:px(46,w));Text(title).font(.system(size:px(28,w))).foregroundStyle(.white);Spacer();Image(systemName:"chevron.right").foregroundStyle(.white.opacity(0.7))}.padding(.vertical,px(15,w))}
}
@MainActor final class UserCenterViewModel:ObservableObject{@Published var userInfo:PersonalCenter?;@Published var errorMessage:String?;func load()async{guard TokenStore.shared.token != nil else{return};do{let r:APIEnvelope<PersonalCenter>=try await APIClient.shared.request(path:"community/fruser/personalCenter",method:"GET",body:EmptyBody());userInfo=r.data}catch{errorMessage=error.localizedDescription}};func logout()async{_ = try? await APIClient.shared.request(path:"token/logout",method:"DELETE",body:EmptyBody()) as EmptyResponse;TokenStore.shared.clear();userInfo=nil}}
struct PersonalCenter:Decodable{let headPortrait:String?;let nickName:String?;let goldBalance:Int?;let city:String?;let blogCount:Int?;let followCount:Int?;let fansCount:Int?}
