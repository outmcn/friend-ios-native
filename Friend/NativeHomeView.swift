import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @State private var musicOn = true
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                FriendHomeBackground()
                VStack(spacing: 0) {
                    topBar.padding(.top, proxy.safeAreaInsets.top + 8)
                    Spacer()
                    mainActions
                    Spacer(minLength: 40)
                    bottomBar(proxy: proxy)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("FriendLogo").resizable().scaledToFit().frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 1) {
                Text("谈笑").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text("视频聊，更靠谱").font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.86))
            }
            Spacer()
            Button { musicOn.toggle() } label: { Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: 27, height: 27) }
            Button { } label: {
                HStack(spacing: 5) { Image("FriendScreen").resizable().scaledToFit().frame(width: 13, height: 13); Text("筛选").font(.system(size: 13, weight: .medium)) }
                    .foregroundStyle(.white).padding(.horizontal, 12).frame(height: 30).background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.82), lineWidth: 1))
            }
        }.padding(.horizontal, 18)
    }

    private var mainActions: some View {
        HStack(spacing: 50) { Button { } label: { actionItem(image: "FriendVideoButton", title: "视频匹配") }; Button { } label: { actionItem(image: "FriendStarButton", title: "点缀星空") } }.padding(.horizontal, 28)
    }
    private func actionItem(image: String, title: String) -> some View { VStack(spacing: 10) { Image(image).resizable().scaledToFit().frame(width: 108, height: 108); Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.42), radius: 5) }.frame(maxWidth: .infinity) }

    private func bottomBar(proxy: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            Image("tabbarBackground").resizable().scaledToFill().frame(height: 90).padding(.horizontal, 20).clipped()
            HStack(spacing: 0) { tabItem(0, "tabbar1White", "tabbar1Black", "星空"); tabItem(1, "tabbar2White", "tabbar2Black", "发现"); tabItem(2, "tabbar3White", "tabbar3Black", "消息"); tabItem(3, "tabbar4White", "tabbar4Black", "我的") }
                .padding(.horizontal, 40).frame(height: 82)
        }
        .frame(height: 90).padding(.bottom, max(proxy.safeAreaInsets.bottom, 18))
    }

    private func tabItem(_ index: Int, _ white: String, _ black: String, _ title: String) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 4) { Image(selectedTab == index ? white : black).resizable().scaledToFit().frame(width: 30, height: 30); Text(title).font(.system(size: 12, weight: .bold)).foregroundStyle(Color(red: 0.82, green: 0.87, blue: 0.92)) }.frame(maxWidth: .infinity)
        }
    }
}
