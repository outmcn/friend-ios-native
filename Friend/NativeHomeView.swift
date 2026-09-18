import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @State private var musicOn = true
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack(alignment: .topLeading) {
                FriendHomeBackground()
                header(top: proxy.safeAreaInsets.top)
                entryGrid(width: w, height: h)
                customTabBar(width: w, height: h, bottom: proxy.safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private func header(top: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 7) {
                Text("谈笑").font(.system(size: 30, weight: .bold)).foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
                Text("视频聊，更靠谱").font(.system(size: 18, weight: .regular)).foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
            }
            Spacer()
            Button { musicOn.toggle() } label: { Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: 27, height: 27) }.frame(width: 40, height: 40)
            Button { } label: { HStack(spacing: 5) { Image("FriendScreen").resizable().scaledToFit().frame(width: 13, height: 13); Text("筛选").font(.system(size: 13)) }.foregroundStyle(.white).padding(.horizontal, 12).frame(height: 30).background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.82), lineWidth: 1)) }.padding(.top, 5)
        }.padding(.horizontal, 28).padding(.top, top + 24)
    }

    private func entryGrid(width: CGFloat, height: CGFloat) -> some View {
        let artSize = min(width * 0.30, 112)
        return HStack(spacing: 0) {
            Button { } label: { entry(image: "FriendVideoButton", title: "视频匹配", size: artSize) }.frame(width: width * 0.5)
            Button { } label: { entry(image: "FriendStarButton", title: "点缀星空", size: artSize) }.frame(width: width * 0.5)
        }
        .position(x: width / 2, y: height * 0.315)
    }

    private func entry(image: String, title: String, size: CGFloat) -> some View {
        VStack(spacing: 13) { Image(image).resizable().scaledToFit().frame(width: size, height: size); Text(title).font(.system(size: 18, weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.42), radius: 5) }
    }

    private func customTabBar(width: CGFloat, height: CGFloat, bottom: CGFloat) -> some View {
        let barHeight: CGFloat = 112
        return ZStack {
            RoundedRectangle(cornerRadius: 48).fill(Color.black.opacity(0.28)).overlay(RoundedRectangle(cornerRadius: 48).stroke(Color.white.opacity(0.22), lineWidth: 1))
            HStack(spacing: 0) { tabItem(0, "tabbar1White", "tabbar1Black", "星空"); tabItem(1, "tabbar2White", "tabbar2Black", "发现"); tabItem(2, "tabbar3White", "tabbar3Black", "消息"); tabItem(3, "tabbar4White", "tabbar4Black", "我的") }.padding(.horizontal, 22).padding(.top, 5).padding(.bottom, bottom + 4)
        }
        .frame(width: width - 32, height: barHeight)
        .position(x: width / 2, y: height - barHeight / 2 - 8)
    }

    private func tabItem(_ index: Int, _ white: String, _ black: String, _ title: String) -> some View {
        Button { selectedTab = index } label: { VStack(spacing: 5) { Image(selectedTab == index ? white : black).resizable().scaledToFit().frame(width: 31, height: 31); Text(title).font(.system(size: 16, weight: .medium)).foregroundStyle(Color(red: 0.82, green: 0.87, blue: 0.92)) }.frame(maxWidth: .infinity) }
    }
}
