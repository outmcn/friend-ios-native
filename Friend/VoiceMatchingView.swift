import SwiftUI

struct VoiceMatchingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = VoiceMatchingViewModel()
    private let designWidth: CGFloat = 750
    private func px(_ rpx: CGFloat, _ width: CGFloat) -> CGFloat { width * rpx / designWidth }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack {
                Color(red: 0.01, green: 0.04, blue: 0.07).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: proxy.safeAreaInsets.top)
                    HStack {
                        Button { dismiss() } label: { Image("FriendWhiteBack").resizable().scaledToFit().frame(width: px(44,w), height: px(44,w)) }
                        Spacer()
                        Text("语音匹配").font(.system(size: px(36,w), weight: .medium)).foregroundStyle(Color(red:0.87,green:0.89,blue:0.98))
                        Spacer()
                        Color.clear.frame(width: px(44,w), height: px(44,w))
                    }.padding(.horizontal, px(32,w))
                    Spacer()
                    ZStack {
                        Image("FriendVideoMatchingRing").resizable().scaledToFit().frame(width: w, height: px(758,w)).opacity(0.72)
                        Circle().fill(Color(red:0.57,green:0.62,blue:0.89)).frame(width:px(202,w),height:px(204,w)).overlay(Circle().stroke(Color(red:0.72,green:0.75,blue:0.93),lineWidth:px(10,w))).shadow(color:.indigo.opacity(0.7),radius:px(8,w))
                        Image(systemName: "waveform").font(.system(size: px(58,w), weight: .medium)).foregroundStyle(.white)
                    }.frame(width:w,height:px(300,w))
                    Spacer()
                    HStack(spacing: px(12,w)) {
                        voiceButton(title: "加速匹配", type: "SENIOR", width: w)
                        voiceButton(title: "普通匹配", type: "ORDINARY", width: w)
                    }.frame(width:px(572,w),height:px(74,w))
                    if model.isMatching { ProgressView().tint(.white).padding(.top, 20) }
                    if let error = model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).padding(.top, 10) }
                    Spacer(minLength: proxy.safeAreaInsets.bottom + 24)
                }
            }
        }.navigationBarHidden(true).task { await model.load() }.onDisappear { Task { await model.stop() } }
    }

    private func voiceButton(title: String, type: String, width: CGFloat) -> some View {
        Button { Task { await model.start(type: type) } } label: {
            HStack(spacing: px(12,width)) { Image(systemName: "waveform").font(.system(size: px(25,width))); Text(title).font(.system(size:px(28,width),weight:.medium)) }
                .foregroundStyle(Color(red: 0.95, green: 0.80, blue: 0.38)).frame(maxWidth:.infinity).frame(height:px(74,width))
                .background(Color(red: 0.95, green: 0.80, blue: 0.38).opacity(0.18)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red: 0.95, green: 0.80, blue: 0.38),lineWidth:2))
        }
    }
}

@MainActor final class VoiceMatchingViewModel: ObservableObject {
    @Published var isMatching = false
    @Published var errorMessage: String?
    private let service = MatchingService()
    func load() async {}
    func start(type: String) async { let id = 0; isMatching = true; errorMessage = nil; do { try await service.start(type: type, userId: id); _ = try await service.receive() } catch { errorMessage = error.localizedDescription; isMatching = false } }
    func stop() async { service.stop(); isMatching = false }
}
