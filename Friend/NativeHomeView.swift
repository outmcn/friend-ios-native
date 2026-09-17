import SwiftUI

struct NativeHomeView: View {
    @StateObject private var model = DiscoveryViewModel()
    @State private var musicOn = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Image("FriendLogo").resizable().scaledToFit().frame(height: 34)
                    Spacer()
                    Button { musicOn.toggle() } label: {
                        Image(musicOn ? "FriendMusicWhite" : "FriendMusicBlack")
                            .resizable().scaledToFit().frame(width: 25, height: 25)
                    }
                    Button { } label: {
                        HStack(spacing: 4) {
                            Image("FriendScreen").resizable().scaledToFit().frame(width: 16, height: 16)
                            Text("筛选").font(.footnote)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Image("FriendScreenBackground").resizable().scaledToFill())
                        .clipShape(Capsule())
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.top, 12)

                if model.isLoading { ProgressView().tint(.white).padding(.top, 50) }
                else if let error = model.errorMessage { Text(error).foregroundStyle(.red).padding(.top, 50) }
                else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(model.users) { user in
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: user.headPortrait ?? "")) { image in image.resizable().scaledToFill() } placeholder: { Color.gray }
                                        .frame(width: 54, height: 54).clipShape(Circle())
                                    Text(user.nickName ?? "用户").foregroundStyle(.white).font(.headline)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }.padding(.top, 20)
                    }
                }
                Spacer()
                HStack(spacing: 24) {
                    Button { } label: { VStack { Image(systemName: "sparkles"); Text("星空") } }
                    Button { } label: { VStack { Image(systemName: "person.2"); Text("发现") } }
                    Button { } label: { VStack { Image(systemName: "message"); Text("消息") } }
                    Button { } label: { VStack { Image(systemName: "person"); Text("我的") } }
                }
                .font(.caption).foregroundStyle(.white).padding(.vertical, 12)
            }
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }
}
