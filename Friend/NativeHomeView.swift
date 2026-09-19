import SwiftUI

struct NativeHomeView: View {
    @StateObject private var music = BackgroundMusicPlayer.shared
    @State private var selectedTab = 0
    @State private var showMatching = false
    @State private var showMatchingSheet = false
    @State private var showSearch = false
    @State private var showStarInfo = false
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
        .background(NavigationLink(destination: VoiceMatchingView(), isActive: $showMatching) { EmptyView() })
        .sheet(isPresented: $showSearch) { HomeSearchSheet() }
        .sheet(isPresented: $showStarInfo) { StarInfoSheet() }
        .sheet(isPresented: $showMatchingSheet) { VideoMatchingSheet() }
    }

    @ViewBuilder private func tabContent(width: CGFloat, height: CGFloat, top: CGFloat, bottomInset: CGFloat) -> some View {
        switch selectedTab {
        case 1: DiscoveryView().overlay(alignment: .bottom) { sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
        case 2: MessageView().overlay(alignment: .bottom) { sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
        case 3: sourceUserTab(width: width, height: height, top: top, bottomInset: bottomInset)
        default: homeContent(width: width, height: height, top: top, bottomInset: bottomInset)
        }
    }

    private func sourceBlankTab(width: CGFloat, height: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) { Color.clear; sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
    }

    private func sourceUserTab(width: CGFloat, height: CGFloat, top: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) { UserCenterView(topSafeArea: top); sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
    }

    private func homeContent(width: CGFloat, height: CGFloat, top: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) { sourceHeader(width: width, top: top); sourceFunctionButtons(width: width, height: height, top: top); starPlaceholders(width: width, height: height, top: top); sourceTabBar(width: width, height: height, bottomInset: bottomInset) }
    }

    private func starPlaceholders(width: CGFloat, height: CGFloat, top: CGFloat) -> some View {
        let gap = px(14, width), cardWidth = (width - px(64, width) - gap) / 2
        return VStack(spacing: gap) {
            HStack(spacing: gap) { placeholderCard(width: cardWidth, height: px(120, width), tint: Color(red:0.18,green:0.48,blue:0.94), icon: "bolt.fill"); placeholderCard(width: cardWidth, height: px(120, width), tint: Color(red:0.50,green:0.23,blue:0.84), icon: "headphones") }
            HStack(spacing: gap) { placeholderCard(width: cardWidth, height: px(120, width), tint: Color(red:0.92,green:0.26,blue:0.65), icon: "sparkles"); placeholderCard(width: cardWidth, height: px(120, width), tint: Color(red:0.95,green:0.34,blue:0.52), icon: "heart.fill") }
            HStack(spacing: gap) { placeholderCard(width: cardWidth, height: px(120, width), tint: Color(red:0.58,green:0.25,blue:0.78), icon: "wineglass.fill"); placeholderCard(width: cardWidth, height: px(120, width), tint: Color(red:0.89,green:0.90,blue:0.96), icon: "ghost.fill", darkIcon: true) }
        }.padding(.horizontal, px(32, width)).padding(.top, top + px(112, width)).padding(.bottom, px(150, width)).frame(maxWidth: .infinity).position(x: width / 2, y: height * 0.70)
    }

    private func placeholderCard(width: CGFloat, height: CGFloat, tint: Color, icon: String, darkIcon: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: px(16, width)).fill(LinearGradient(colors: [tint.opacity(0.95), tint.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: width, height: height).overlay(alignment: .center) { Image(systemName: icon).font(.system(size: min(width, height) * 0.28, weight: .bold)).foregroundStyle(darkIcon ? .black.opacity(0.55) : .white.opacity(0.92)) }.overlay(alignment: .bottomLeading) { Text("占位内容").font(.system(size: px(16, width), weight: .medium)).foregroundStyle(darkIcon ? .black.opacity(0.65) : .white.opacity(0.85)).padding(.leading, px(14, width)).padding(.bottom, px(12, width)) }
    }

    private func sourceHeader(width: CGFloat, top: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: top + px(27, width))
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                HStack(spacing: px(20, width)) {
                    Button { music.toggle() } label: { Image(music.isPlaying ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: px(54, width), height: px(54, width)) }
                    Button { showSearch = true } label: { HStack(spacing: px(8, width)) { Image("FriendScreen").resizable().scaledToFit().frame(width: px(20, width), height: px(20, width)); Text("筛选").font(.system(size: px(24, width))) }.foregroundStyle(.white).frame(width: px(120, width), height: px(54, width)).background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule()).overlay(Capsule().stroke(.white, lineWidth: px(2, width))) }
                }
            }.padding(.horizontal, px(56, width))
        }
    }

    private func sourceFunctionButtons(width: CGFloat, height: CGFloat, top: CGFloat) -> some View {
        let icon = px(128, width), groupHeight = icon + px(28, width) + px(45, width)
        return HStack(spacing: 0) { Button { showStarInfo = true } label: { sourceFunction(image: "FriendStarButton", title: "点缀星空", width: width, icon: icon) }.frame(width: width / 2); Button { showMatchingSheet = true } label: { sourceFunction(image: "FriendVideoButton", title: "视频匹配", width: width, icon: icon) }.frame(width: width / 2) }.frame(width: width, height: groupHeight).position(x: width / 2, y: top + px(210, width) + groupHeight / 2)
    }
    private func sourceFunction(image: String, title: String, width: CGFloat, icon: CGFloat) -> some View { VStack(spacing: px(28, width)) { Image(image).resizable().scaledToFit().frame(width: icon, height: icon); ZStack { Image("FriendTextBackground").resizable().scaledToFill(); Text(title).font(.system(size: px(32, width), weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.56), radius: px(10, width)) }.frame(width: px(159, width), height: px(45, width)) } }

    private func sourceTabBar(width: CGFloat, height: CGFloat, bottomInset: CGFloat) -> some View {
        let barHeight = px(132, width), bottom: CGFloat = 34
        return ZStack { Image("tabbarBackground").resizable().scaledToFit().frame(width: width, height: barHeight); HStack(spacing: 0) { sourceTab(0,"tabbar1White","tabbar1Black","星空",width); sourceTab(1,"tabbar2White","tabbar2Black","发现",width); sourceTab(2,"tabbar3White","tabbar3Black","消息",width); sourceTab(3,"tabbar4White","tabbar4Black","我的",width) }.padding(.horizontal, px(40,width)).frame(width: width,height: barHeight) }.frame(width: width,height: barHeight).position(x: width/2,y: height-bottom-barHeight/2)
    }
    private func sourceTab(_ i:Int,_ selected:String,_ normal:String,_ title:String,_ width:CGFloat)->some View { Button { selectedTab = i } label: { VStack(spacing:0) { Image(selectedTab==i ? selected:normal).resizable().scaledToFit().frame(width:px(58,width),height:px(58,width)); Text(title).font(.system(size:px(18,width),weight:.bold)).foregroundStyle(Color(red:0.82,green:0.87,blue:0.92)) }.frame(maxWidth:.infinity,maxHeight:.infinity) } }
}
