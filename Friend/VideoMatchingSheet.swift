import SwiftUI

struct VideoMatchingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = VideoMatchingViewModel()
    private let designWidth: CGFloat = 750
    private func px(_ rpx: CGFloat, _ width: CGFloat) -> CGFloat { width * rpx / designWidth }
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack {
                Image("FriendVideoMatchingBg").resizable().scaledToFill().ignoresSafeArea()
                Color.black.opacity(0.12).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: 12)
                    ZStack {
                        Image("FriendVideoMatchingRing").resizable().scaledToFit().frame(width: w, height: px(520,w))
                        Circle().fill(Color(red:0.57,green:0.62,blue:0.89)).frame(width:px(150,w),height:px(152,w)).overlay(Circle().stroke(Color(red:0.72,green:0.75,blue:0.93),lineWidth:px(8,w))).shadow(color:.indigo.opacity(0.7),radius:px(8,w))
                        if let avatar = model.avatarURL { RemoteAvatar(urlString: avatar, size: px(118,w)) } else { Image(systemName:"person.fill").font(.system(size:px(42,w))).foregroundStyle(.white.opacity(0.8)) }
                    }.frame(width:w,height:px(520,w),alignment:.center).padding(.top, px(16,w))
                    HStack(spacing:px(12,w)) { matchButton(title:"加速匹配",type:"SENIOR",icon:true,width:w); matchButton(title:"普通匹配",type:"ORDINARY",icon:false,width:w) }.frame(width:px(572,w),height:px(74,w)).padding(.top,px(12,w))
                    if model.isMatching { ProgressView().tint(.white).padding(.top, 12) }
                    if let error=model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).padding(.top,8) }
                    Spacer()
                }
            }
        }.task { await model.load() }
    }
    private func matchButton(title:String,type:String,icon:Bool,width:CGFloat)->some View { Button { Task { await model.start(type:type) } } label:{ HStack(spacing:px(14,width)){if icon{Image("FriendVideoMatchingIcon1").resizable().frame(width:px(44,width),height:px(48,width))};Text(title).font(.system(size:px(28,width),weight:.medium))}.foregroundStyle(Color(red:0.95,green:0.80,blue:0.38)).frame(maxWidth:.infinity).frame(height:px(74,width)).background(Color(red:0.95,green:0.80,blue:0.38).opacity(0.18)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.95,green:0.80,blue:0.38),lineWidth:2)) } }
}
