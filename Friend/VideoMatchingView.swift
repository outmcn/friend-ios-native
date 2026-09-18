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
                Image("FriendVideoMatchingBg").resizable().scaledToFill().ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack { Button { dismiss() } label: { Image(systemName: "chevron.left").font(.title2).foregroundStyle(.white) }; Spacer(); Text("视频匹配").font(.system(size: px(36,w), weight: .bold)).foregroundStyle(.white); Spacer(); Color.clear.frame(width: 28) }.padding(.horizontal, px(32,w)).padding(.top, proxy.safeAreaInsets.top + px(20,w))
                    ZStack {
                        Image("FriendVideoMatchingRing").resizable().scaledToFit().frame(width: w, height: px(758,w))
                        Circle().fill(Color(red:0.57,green:0.62,blue:0.89)).frame(width:px(202,w),height:px(204,w)).overlay(Circle().stroke(Color(red:0.72,green:0.75,blue:0.93),lineWidth:px(10,w))).shadow(color:.indigo.opacity(0.7),radius:px(8,w))
                        if let avatar = model.avatarURL { RemoteAvatar(urlString: avatar, size: px(158,w)) }
                    }.frame(width:w,height:px(758,w)).padding(.top,px(48,w))
                    HStack(spacing: px(12,w)) {
                        matchButton(title:"加速匹配", type:"SENIOR", icon:true, width:w)
                        matchButton(title:"普通匹配", type:"ORDINARY", icon:false, width:w)
                    }.frame(width:px(572,w),height:px(74,w)).padding(.top,px(20,w))
                    if model.isMatching { ProgressView().tint(.white).padding(.top, 20) }
                    if let error = model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).padding(.top, 10) }
                    Spacer()
                }
            }
        }.navigationBarHidden(true).task { await model.load() }
    }

    private func matchButton(title: String, type: String, icon: Bool, width: CGFloat) -> some View {
        Button { Task { await model.start(type: type) } } label: { HStack(spacing:px(14,width)) { if icon { Image("FriendVideoMatchingIcon1").resizable().frame(width:px(44,width),height:px(48,width)) }; Text(title).font(.system(size:px(28,width),weight:.medium)) }.foregroundStyle(Color(red:0.95,green:0.80,blue:0.38)).frame(maxWidth:.infinity).frame(height:px(74,width)).background(Color(red:0.95,green:0.80,blue:0.38).opacity(0.18)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.95,green:0.80,blue:0.38),lineWidth:2)) }
    }
}

@MainActor final class VideoMatchingViewModel: ObservableObject {
    @Published var avatarURL: String?
    @Published var isMatching = false
    @Published var errorMessage: String?
    private let service = MatchingService()
    func load() async { avatarURL = nil }
    func start(type: String) async {
        guard let id = 0 as Int? else { return }
        isMatching = true; errorMessage = nil
        do { try await service.start(type: type, userId: id); let match = try await service.receive(); avatarURL = match.headPortrait }
        catch { errorMessage = error.localizedDescription; isMatching = false }
    }
    deinit { Task { await service.stop() } }
}
