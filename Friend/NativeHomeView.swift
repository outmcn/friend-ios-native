import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @StateObject private var music = BackgroundMusicPlayer.shared
    @State private var selectedTab = 0
    @State private var showMatching = false
    private let designWidth: CGFloat = 750
    private func px(_ rpx: CGFloat, _ width: CGFloat) -> CGFloat { width * rpx / designWidth }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            let topSafe = max(proxy.safeAreaInsets.top, 44)
            let bottomSafe = max(proxy.safeAreaInsets.bottom, 34)
            ZStack(alignment: .topLeading) {
                FriendHomeBackground().ignoresSafeArea()
                tabContent(width: w, height: h, top: topSafe, bottomInset: bottomSafe)
            }
        }
        .ignoresSafeArea()
        .background(NavigationLink(destination: Text("视频匹配"), isActive: $showMatching) { EmptyView() })
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    @ViewBuilder private func tabContent(width: CGFloat, height: CGFloat, top: CGFloat, bottomInset: CGFloat) -> some View {
        switch selectedTab {
        case 1: sourceBlankTab(width: width, height: height, bottomInset: bottomInset)
        case 2: sourceBlankTab(width: width, height: height, bottomInset: bottomInset)
        case 3: sourceUserTab(width: width, height: height, bottomInset: bottomInset)
        default: homeContent(width: width, height: height, top: top, bottomInset: bottomInset)
        }
    }

    private func sourceBlankTab(width: CGFloat, height: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) { Color.clear; sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
    }

    private func sourceUserTab(width: CGFloat, height: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) { UserCenterView(); sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
    }

    private func homeContent(width: CGFloat, height: CGFloat, top: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) { sourceHeader(width: width, top: top); sourceFunctionButtons(width: width, height: height); sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
    }

    private func sourceHeader(width: CGFloat, top: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: top + px(27, width))
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                HStack(spacing: px(20, width)) {
                    Button { music.toggle() } label: { Image(music.isPlaying ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: px(54, width), height: px(54, width)) }
                    Button { } label: { HStack(spacing: px(8, width)) { Image("FriendScreen").resizable().scaledToFit().frame(width: px(20, width), height: px(20, width)); Text("筛选").font(.system(size: px(24, width))) }.foregroundStyle(.white).frame(width: px(120, width), height: px(54, width)).background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule()).overlay(Capsule().stroke(.white, lineWidth: px(2, width))) }
                }
            }.padding(.horizontal, px(56, width))
        }
    }

    private func sourceFunctionButtons(width: CGFloat, height: CGFloat) -> some View {
        let icon = px(128, width), groupHeight = icon + px(28, width) + px(45, width)
        return HStack(spacing: 0) { Button { showMatching = true } label: { sourceFunction(image: "FriendVideoButton", title: "视频匹配", width: width, icon: icon) }.frame(width: width / 2); Button { } label: { sourceFunction(image: "FriendStarButton", title: "点缀星空", width: width, icon: icon) }.frame(width: width / 2) }.frame(width: width, height: groupHeight).position(x: width / 2, y: height - px(266, width) - groupHeight / 2)
    }
    private func sourceFunction(image: String, title: String, width: CGFloat, icon: CGFloat) -> some View { VStack(spacing: px(28, width)) { Image(image).resizable().scaledToFit().frame(width: icon, height: icon); ZStack { Image("FriendTextBackground").resizable().scaledToFill(); Text(title).font(.system(size: px(32, width), weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.56), radius: px(10, width)) }.frame(width: px(159, width), height: px(45, width)) } }

    private func sourceTabBar(width: CGFloat, height: CGFloat, bottomInset: CGFloat) -> some View {
        let barHeight = px(132, width), bottom: CGFloat = 34
        return ZStack { Image("tabbarBackground").resizable().scaledToFit().frame(width: width, height: barHeight); HStack(spacing: 0) { sourceTab(0,"tabbar1White","tabbar1Black","星空",width); sourceTab(1,"tabbar2White","tabbar2Black","发现",width); sourceTab(2,"tabbar3White","tabbar3Black","消息",width); sourceTab(3,"tabbar4White","tabbar4Black","我的",width) }.padding(.horizontal, px(40,width)).frame(width: width,height: barHeight) }.frame(width: width,height: barHeight).position(x: width/2,y: height-bottom-barHeight/2)
    }
    private func sourceTab(_ i:Int,_ selected:String,_ normal:String,_ title:String,_ width:CGFloat)->some View { Button { selectedTab = i } label: { VStack(spacing:0) { Image(selectedTab==i ? selected:normal).resizable().scaledToFit().frame(width:px(44,width),height:px(44,width)); Text(title).font(.system(size:px(18,width),weight:.bold)).foregroundStyle(Color(red:0.82,green:0.87,blue:0.92)) }.frame(maxWidth:.infinity,maxHeight:.infinity) } }
}
