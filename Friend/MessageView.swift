import SwiftUI

struct MessageView: View {
    @State private var search = ""
    @State private var messages = MessageItem.placeholders
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.02, green: 0.03, blue: 0.07).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: max(proxy.safeAreaInsets.top, 44))
                    header
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) { ForEach(filtered) { item in messageRow(item) } }.padding(.bottom, 120)
                    }
                }
            }
        }.navigationBarHidden(true)
    }
    private var filtered: [MessageItem] { search.isEmpty ? messages : messages.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.preview.localizedCaseInsensitiveContains(search) } }
    private var header: some View {
        VStack(spacing: 12) {
            HStack { Text("消息").font(.system(size: 28, weight: .bold)).foregroundStyle(.white); Spacer(); Button { } label: { Image(systemName: "square.and.pencil").font(.system(size: 21)).foregroundStyle(.white) } }.padding(.horizontal, 20)
            HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("搜索消息", text: $search).foregroundStyle(.primary).tint(.primary) }.padding(.horizontal, 14).frame(height: 42).background(Color.white.opacity(0.10)).clipShape(Capsule()).padding(.horizontal, 16)
        }.padding(.top, 18).padding(.bottom, 12)
    }
    private func messageRow(_ item: MessageItem) -> some View {
        Button { } label: { HStack(spacing: 12) { Circle().fill(item.color).frame(width: 54, height: 54).overlay(Image(systemName: item.icon).foregroundStyle(.white).font(.system(size: 22))); VStack(alignment: .leading, spacing: 6) { HStack { Text(item.name).font(.system(size: 17, weight: .medium)).foregroundStyle(.white); Spacer(); Text(item.time).font(.caption).foregroundStyle(.white.opacity(0.48)) }; Text(item.preview).font(.system(size: 14)).foregroundStyle(.white.opacity(0.58)).lineLimit(1) }; Spacer() }.padding(.horizontal, 20).frame(height: 82).overlay(alignment: .bottom) { Color.white.opacity(0.08).frame(height: 1).padding(.leading, 86) } }.buttonStyle(.plain)
    }
}

struct MessageItem: Identifiable {
    let id = UUID(); let name: String; let preview: String; let time: String; let icon: String; let color: Color
    static let placeholders = [MessageItem(name: "系统消息", preview: "欢迎来到谈笑", time: "刚刚", icon: "bell.fill", color: .purple), MessageItem(name: "匹配消息", preview: "等待新的匹配消息", time: "昨天", icon: "waveform", color: .blue), MessageItem(name: "好友消息", preview: "暂无新的聊天消息", time: "", icon: "person.2.fill", color: .pink)]
}
