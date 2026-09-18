import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @State private var musicOn = true
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                FriendHomeBackground()
                sourceHeader(top: proxy.safeAreaInsets.top)
                sourceFunctionButtons(width: proxy.size.width, height: proxy.size.height)
                sourceTabBar(width: proxy.size.width, height: proxy.size.height)
            }
            .ignoresSafeArea()
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private func sourceHeader(top: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: top + 27)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("谈笑").font(.system(size: 24, weight: .bold)).foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
                    Text("视频聊，更靠谱").font(.system(size: 18, weight: .regular)).foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98)).padding(.top, 17)
                }
                Spacer()
                HStack(spacing: 10) {
                    Button { musicOn.toggle() } label: { Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: 27, height: 27) }
                    Button { } label: { HStack(spacing: 5) { Image("FriendScreen").resizable().scaledToFit().frame(width: 13, height: 13); Text("筛选").font(.system(size: 13)) }.foregroundStyle(.white).padding(.horizontal, 12).frame(height: 30).background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.82), lineWidth: 1)) }
                }
            }.padding(.horizontal, 56)
        }
    }

    private func sourceFunctionButtons(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            Button { } label: { sourceFunction(image: "FriendVideoButton", title: "视频匹配", width: width * 0.5) }.frame(width: width * 0.5)
            Button { } label: { sourceFunction(image: "FriendStarButton", title: "点缀星空", width: width * 0.5) }.frame(width: width * 0.5)
        }
        // Source: position: fixed; bottom: 266rpx. On a 750px design width, 266rpx = 0.3547 * width.
        .position(x: width / 2, y: height - width * 0.3547 - 64)
    }

    private func sourceFunction(image: String, title: String, width: CGFloat) -> some View {
        VStack(spacing: 10) {
            Image(image).resizable().scaledToFit().frame(width: min(width * 0.3413, 128), height: min(width * 0.3413, 128))
            Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.42), radius: 5)
        }
    }

    private func sourceTabBar(width: CGFloat, height: CGFloat) -> some View {
        let barHeight = width * 0.176
        let bottom = width * 0.064
        return ZStack {
            Image("tabbarBackground").resizable().scaledToFill().frame(width: width, height: barHeight).clipped()
            HStack(spacing: 0) {
                sourceTab(0, "tabbar1White", "tabbar1Black", "星空")
                sourceTab(1, "tabbar2White", "tabbar2Black", "发现")
                sourceTab(2, "tabbar3White", "tabbar3Black", "消息")
                sourceTab(3, "tabbar4White", "tabbar4Black", "我的")
            }.padding(.horizontal, width * 0.0533).frame(width: width, height: barHeight)
        }
        // Source: position: fixed; bottom: 48rpx. No extra iOS safe-area padding.
        .frame(width: width, height: barHeight)
        .position(x: width / 2, y: height - bottom - barHeight / 2)
    }

    private func sourceTab(_ index: Int, _ selected: String, _ normal: String, _ title: String) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 4) {
                Image(selectedTab == index ? selected : normal).resizable().scaledToFit().frame(width: 31, height: 31)
                Text(title).font(.system(size: 12, weight: .bold)).foregroundStyle(Color(red: 0.82, green: 0.87, blue: 0.92))
            }.frame(maxWidth: .infinity)
        }
    }
}
