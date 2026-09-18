import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @State private var musicOn = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            FriendHomeBackground()
            VStack(spacing: 0) {
                topBar
                Spacer()
                mainActions
                Spacer(minLength: 70)
                bottomBar
            }
            .padding(.top, 8)
        }
        .task { await model.load() }
        .refreshable { await model.load() }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("FriendLogo").resizable().scaledToFit().frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 1) {
                Text("谈笑").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text("视频聊，更靠谱").font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.86))
            }
            Spacer()
            Button { musicOn.toggle() } label: {
                Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack").resizable().scaledToFit().frame(width: 27, height: 27)
            }
            Button { } label: {
                HStack(spacing: 5) { Image("FriendScreen").resizable().scaledToFit().frame(width: 13, height: 13); Text("筛选").font(.system(size: 13, weight: .medium)) }
                    .foregroundStyle(.white).padding(.horizontal, 12).frame(height: 30)
                    .background(Image("FriendScreenBackground").resizable().scaledToFill()).clipShape(Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.82), lineWidth: 1))
            }
        }
        .padding(.horizontal, 18)
    }

    private var mainActions: some View {
        HStack(spacing: 50) {
            Button { } label: { actionItem(image: "FriendVideoButton", title: "视频匹配") }
            Button { } label: { actionItem(image: "FriendStarButton", title: "点缀星空") }
        }
        .padding(.horizontal, 28)
    }

    private func actionItem(image: String, title: String) -> some View {
        VStack(spacing: 10) {
            Image(image).resizable().scaledToFit().frame(width: 108, height: 108)
            Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).shadow(color: .white.opacity(0.42), radius: 5)
        }.frame(maxWidth: .infinity)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            tabItem("sparkles", "星空", 0); tabItem("person.2", "发现", 1); tabItem("message", "消息", 2); tabItem("person", "我的", 3)
        }
        .padding(.horizontal, 18).padding(.bottom, 12)
    }

    private func tabItem(_ icon: String, _ title: String, _ index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 5) { Image(systemName: icon).font(.system(size: 22, weight: .medium)); Text(title).font(.system(size: 12, weight: .medium)) }
                .foregroundStyle(.white.opacity(selectedTab == index ? 1 : 0.86)).frame(maxWidth: .infinity)
        }
    }
}
