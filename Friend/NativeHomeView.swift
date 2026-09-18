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
                    topBar.padding(.top, 0)
                    Spacer(minLength: 0)
                    mainActions
                        .offset(y: -150)
                    Spacer(minLength: 0)
                    bottomBar(proxy: proxy)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private var topBar: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("谈笑").font(.system(size: 24, weight: .bold)).foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
                Text("视频聊，更靠谱").font(.system(size: 18, weight: .regular)).foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
            }
            Spacer(minLength: 8)
            Button { musicOn.toggle() } label: { Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: 27, height: 27) }
            Button { } label: {
                HStack(spacing: 5) { Image("FriendScreen").resizable().scaledToFit().frame(width: 13, height: 13); Text("筛选").font(.system(size: 13, weight: .regular)) }
                    .foregroundStyle(.white).padding(.horizontal, 12).frame(height: 30).background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule()).overlay(Capsule().stroke(.white.opacity(0.82), lineWidth: 1))
            }
        }.padding(.horizontal, 28)
    }

    private var mainActions: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Button { } label: { actionItem(image: "FriendVideoButton", title: "视频匹配") }.frame(width: proxy.size.width * 0.5)
                Button { } label: { actionItem(image: "FriendStarButton", title: "点缀星空") }.frame(width: proxy.size.width * 0.5)
            }
        }.frame(height: 170)
    }

    private func actionItem(image: String, title: String) -> some View {
        VStack(spacing: 10) { Image(image).resizable().scaledToFit().frame(width: 108, height: 108); Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.42), radius: 5) }
    }

    private func bottomBar(proxy: GeometryProxy) -> some View {
        ZStack {
            Image("tabbarBackground").resizable().scaledToFit().frame(maxWidth: .infinity).padding(.horizontal, 0)
            HStack(spacing: 0) { tabItem(0, "tabbar1White", "tabbar1Black", "星空"); tabItem(1, "tabbar2White", "tabbar2Black", "发现"); tabItem(2, "tabbar3White", "tabbar3Black", "消息"); tabItem(3, "tabbar4White", "tabbar4Black", "我的") }.padding(.horizontal, 40)
        }
        .frame(height: 94)
        .padding(.bottom, proxy.safeAreaInsets.bottom)
    }

    private func tabItem(_ index: Int, _ white: String, _ black: String, _ title: String) -> some View {
        Button { selectedTab = index } label: { VStack(spacing: 4) { Image(selectedTab == index ? white : black).resizable().scaledToFit().frame(width: 30, height: 30); Text(title).font(.system(size: 12, weight: .bold)).foregroundStyle(Color(red: 0.82, green: 0.87, blue: 0.92)) }.frame(maxWidth: .infinity) }
    }
}
