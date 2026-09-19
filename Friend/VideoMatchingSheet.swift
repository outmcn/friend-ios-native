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
                GeometryReader { content in
                    let circleHeight = min(px(520,w), content.size.height * 0.58)
                    let buttonHeight = px(74,w)
                    let groupHeight = circleHeight + px(12,w) + buttonHeight
                    VStack(spacing: 0) {
                        ZStack {
                            Image("FriendVideoMatchingRing").resizable().scaledToFit().frame(width: w, height: circleHeight)
                            Circle().fill(Color(red:0.57,green:0.62,blue:0.89)).frame(width:px(150,w),height:px(152,w)).overlay(Circle().stroke(Color(red:0.72,green:0.75,blue:0.93),lineWidth:px(8,w))).shadow(color:.indigo.opacity(0.7),radius:px(8,w))
                            if let avatar = model.avatarURL { RemoteAvatar(urlString: avatar, size: px(118,w)) } else { Image(systemName:"person.fill").font(.system(size:px(42,w))).foregroundStyle(.white.opacity(0.8)) }
                        }.frame(width:w,height:circleHeight)
                        HStack(spacing:px(12,w)) { matchButton(title:"加速匹配",type:"SENIOR",icon:true,width:w); matchButton(title:"普通匹配",type:"ORDINARY",icon:false,width:w) }.frame(width:px(572,w),height:buttonHeight).padding(.top,px(12,w))
                        if model.isMatching { ProgressView().tint(.white).padding(.top, 12) }
                        if let error=model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).padding(.top,8) }
                    }.frame(maxWidth:.infinity).frame(height:groupHeight).position(x:content.size.width/2,y:content.size.height/2)
                }
            }
        }.task { await model.load() }
    }
    private func matchButton(title:String,type:String,icon:Bool,width:CGFloat)->some View { Button { Task { await model.start(type:type) } } label:{ HStack(spacing:px(14,width)){if icon{Image("FriendVideoMatchingIcon1").resizable().frame(width:px(44,width),height:px(48,width))};Text(title).font(.system(size:px(28,width),weight:.medium))}.foregroundStyle(Color(red:0.95,green:0.80,blue:0.38)).frame(maxWidth:.infinity).frame(height:px(74,width)).background(Color(red:0.95,green:0.80,blue:0.38).opacity(0.18)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.95,green:0.80,blue:0.38),lineWidth:2)) } }
}
