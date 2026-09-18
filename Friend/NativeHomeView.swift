import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @State private var musicOn = true
    @State private var selectedTab = 0

    // Uni-app uses a 750rpx design width. All source dimensions below are converted from rpx.
    private let designWidth: CGFloat = 750
    private func px(_ rpx: CGFloat, width: CGFloat) -> CGFloat { width * rpx / designWidth }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack(alignment: .topLeading) {
                FriendHomeBackground()
                sourceHeader(width: width, top: proxy.safeAreaInsets.top)
                sourceFunctionButtons(width: width, height: height)
                sourceTabBar(width: width, height: height)
            }
            .ignoresSafeArea()
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private func sourceHeader(width: CGFloat, top: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Source status-bar component: APP-PLUS uses the actual system status-bar height.
            Color.clear.frame(height: top)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("谈笑")
                        .font(.system(size: px(48, width: width), weight: .bold))
                        .foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
                    Text("视频聊，更靠谱")
                        .font(.system(size: px(36, width: width), weight: .regular))
                        .foregroundStyle(Color(red: 0.87, green: 0.89, blue: 0.98))
                        .padding(.top, px(34, width: width))
                }
                Spacer()
                HStack(spacing: px(20, width: width)) {
                    Button { musicOn.toggle() } label: {
                        Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack")
                            .resizable().scaledToFit()
                            .frame(width: px(54, width: width), height: px(54, width: width))
                    }
                    Button { } label: {
                        HStack(spacing: px(8, width: width)) {
                            Image("FriendScreen").resizable().scaledToFit().frame(width: px(20, width: width), height: px(20, width: width))
                            Text("筛选").font(.system(size: px(24, width: width)))
                        }
                        .foregroundStyle(.white)
                        .frame(width: px(120, width: width), height: px(54, width: width))
                        .background(Image("FriendScreenBackground").resizable().scaledToFill())
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white, lineWidth: px(2, width: width)))
                    }
                }
            }
            .padding(.horizontal, px(56, width: width))
        }
    }

    private func sourceFunctionButtons(width: CGFloat, height: CGFloat) -> some View {
        let icon = px(128, width: width)
        let title = px(32, width: width)
        let groupHeight = icon + px(28, width: width) + title
        return HStack(spacing: 0) {
            Button { } label: { sourceFunction(image: "FriendVideoButton", title: "视频匹配", width: width, icon: icon) }
                .frame(width: width / 2)
            Button { } label: { sourceFunction(image: "FriendStarButton", title: "点缀星空", width: width, icon: icon) }
                .frame(width: width / 2)
        }
        .frame(width: width, height: groupHeight)
        // Exact source equivalent: position: fixed; left: 0; bottom: 266rpx.
        .position(x: width / 2, y: height - px(266, width: width) - groupHeight / 2)
    }

    private func sourceFunction(image: String, title: String, width: CGFloat, icon: CGFloat) -> some View {
        VStack(spacing: px(28, width: width)) {
            Image(image).resizable().scaledToFit().frame(width: icon, height: icon)
            ZStack {
                Image("FriendTextBackground").resizable().scaledToFill()
                Text(title).font(.system(size: px(32, width: width), weight: .bold)).foregroundStyle(.white).shadow(color: Color(red: 0.87, green: 0.92, blue: 0.97).opacity(0.56), radius: px(10, width: width))
            }
            .frame(width: px(159, width: width), height: px(45, width: width))
        }
    }

    private func sourceTabBar(width: CGFloat, height: CGFloat) -> some View {
        let barHeight = px(132, width: width)
        let bottom = px(48, width: width)
        return ZStack {
            // Source uses background-size: contain, not fill/crop.
            Image("tabbarBackground").resizable().scaledToFit().frame(width: width, height: barHeight)
            HStack(spacing: 0) {
                sourceTab(0, "tabbar1White", "tabbar1Black", "星空", width: width)
                sourceTab(1, "tabbar2White", "tabbar2Black", "发现", width: width)
                sourceTab(2, "tabbar3White", "tabbar3Black", "消息", width: width)
                sourceTab(3, "tabbar4White", "tabbar4Black", "我的", width: width)
            }
            .padding(.horizontal, px(40, width: width))
            .frame(width: width, height: barHeight)
        }
        .frame(width: width, height: barHeight)
        .position(x: width / 2, y: height - bottom - barHeight / 2)
    }

    private func sourceTab(_ index: Int, _ selected: String, _ normal: String, _ title: String, width: CGFloat) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 0) {
                Image(selectedTab == index ? selected : normal).resizable().scaledToFit().frame(width: px(44, width: width), height: px(44, width: width))
                Text(title).font(.system(size: px(18, width: width), weight: .bold)).foregroundStyle(Color(red: 0.82, green: 0.87, blue: 0.92))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
