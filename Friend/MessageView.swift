import SwiftUI

struct MessageView: View {
    @State private var search = ""
    @State private var messages = MessageItem.placeholders
    @State private var selectedGroup = 0
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
    private var filtered: [MessageItem] { let source = selectedGroup == 0 ? messages.filter { $0.name != "好友消息" } : messages.filter { $0.name == "好友消息" }; return search.isEmpty ? source : source.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.preview.localizedCaseInsensitiveContains(search) } }
    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) { ForEach(["消息", "好友"].indices, id: \.self) { i in Button { selectedGroup = i } label: { Text(["消息", "好友"][i]).font(.system(size: i == selectedGroup ? 18 : 16, weight: i == selectedGroup ? .bold : .regular)).foregroundStyle(i == selectedGroup ? .white : .white.opacity(0.55)).frame(maxWidth: .infinity).padding(.vertical, 10).overlay(alignment: .bottom) { if i == selectedGroup { Color(red: 0.95, green: 0.80, blue: 0.38).frame(height: 2) } } } }.padding(.horizontal, 16)
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
