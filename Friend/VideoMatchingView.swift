import SwiftUI

struct VideoMatchingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = VideoMatchingViewModel()
    private let designWidth: CGFloat = 750
    private func px(_ rpx: CGFloat, _ width: CGFloat) -> CGFloat { width * rpx / designWidth }
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack {
                Color(red: 0.01, green: 0.04, blue: 0.07).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: proxy.safeAreaInsets.top)
                    HStack { Button { dismiss() } label: { Image("FriendWhiteBack").resizable().scaledToFit().frame(width:px(44,w),height:px(44,w)) }; Spacer(); Text("视频匹配").font(.system(size:px(36,w),weight:.medium)).foregroundStyle(Color(red:0.87,green:0.89,blue:0.98)).shadow(color:.white.opacity(0.56),radius:px(10,w)); Spacer(); Color.clear.frame(width:px(44,w),height:px(44,w)) }.padding(.horizontal,px(32,w))
                    if model.state == .matching { matchingContent(width:w) } else if model.state == .matched { matchedContent(width:w) } else if model.state == .ended { endedContent(width:w) } else { startContent(width:w) }
                    Spacer()
                }
            }
        }.navigationBarHidden(true).task { await model.load() }.onDisappear { Task { await model.stop() } }
    }
    @ViewBuilder private func startContent(width w:CGFloat)->some View { ZStack { Image("FriendVideoMatchingRing").resizable().scaledToFit().frame(width:w,height:px(758,w)); Circle().fill(Color(red:0.57,green:0.62,blue:0.89)).frame(width:px(202,w),height:px(204,w)).overlay(Circle().stroke(Color(red:0.72,green:0.75,blue:0.93),lineWidth:px(10,w))).shadow(color:.indigo.opacity(0.7),radius:px(8,w)); if let a=model.avatarURL{RemoteAvatar(urlString:a,size:px(158,w))} }.frame(width:w,height:px(758,w)).padding(.top,px(48,w)); HStack(spacing:px(12,w)){matchButton(title:"加速匹配",type:"SENIOR",icon:true,width:w);matchButton(title:"普通匹配",type:"ORDINARY",icon:false,width:w)}.frame(width:px(572,w),height:px(74,w)).padding(.top,px(20,w)) }
    private func matchingContent(width w:CGFloat)->some View { VStack(spacing:12){ProgressView().tint(.white).padding(.top,30);Text("正在匹配中...").foregroundStyle(.white);Text("正在努力寻找与你高度共鸣的Ta").foregroundStyle(.secondary)}.frame(height:px(758,w)) }
    private func matchedContent(width w:CGFloat)->some View { VStack(spacing:16){Text("匹配成功").font(.title2.bold()).foregroundStyle(.white);RemoteAvatar(urlString:model.match?.headPortrait,size:120);Text(model.match?.nickName ?? "").foregroundStyle(.white);Text(model.match?.message ?? "").foregroundStyle(.secondary);Button("立即通话") { model.beginCall() }.buttonStyle(.borderedProminent).tint(Color(red:0.95,green:0.80,blue:0.38)).foregroundStyle(.black)}.frame(height:px(758,w)) }
    private func endedContent(width w:CGFloat)->some View { VStack(spacing:16){Text("通话已结束").font(.title2.bold()).foregroundStyle(.white);RemoteAvatar(urlString:model.match?.headPortrait,size:120);Text(model.match?.nickName ?? "").foregroundStyle(.white);Button("添加好友") {}.buttonStyle(.borderedProminent).tint(Color(red:0.95,green:0.80,blue:0.38)).foregroundStyle(.black)}.frame(height:px(758,w)) }
    private func matchButton(title:String,type:String,icon:Bool,width:CGFloat)->some View { Button{Task{await model.start(type:type)}}label:{HStack(spacing:px(14,width)){if icon{Image("FriendVideoMatchingIcon1").resizable().frame(width:px(44,width),height:px(48,width))};Text(title).font(.system(size:px(28,width),weight:.medium))}.foregroundStyle(Color(red:0.95,green:0.80,blue:0.38)).frame(maxWidth:.infinity).frame(height:px(74,width)).background(Color(red:0.95,green:0.80,blue:0.38).opacity(0.18)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.95,green:0.80,blue:0.38),lineWidth:2))}}
}

@MainActor final class VideoMatchingViewModel: ObservableObject {
    enum State { case idle, matching, matched, ended }
    @Published var state: State = .idle
    @Published var avatarURL: String?
    @Published var match: MatchInfo?
    @Published var errorMessage: String?
    private let service = MatchingService()
    func load() async { avatarURL = UserDefaults.standard.string(forKey:"friend.user.avatar") }
    func start(type:String) async { let id = (try? JSONDecoder().decode(PersonalCenter.self,from:UserDefaults.standard.data(forKey:"friend.user.center.cache") ?? Data()).id) ?? 0; state = .matching; errorMessage=nil; do { try await service.start(type:type,userId:id); match=try await service.receive(); state = .matched } catch { errorMessage=error.localizedDescription; state = .idle } }
    func beginCall() { }
    func stop() async { service.stop(); if state == .matching { state = .idle } }
}
