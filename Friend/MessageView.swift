import Foundation
import SwiftUI

struct MessageView: View {
    @State private var search = ""
    @State private var messages = MessageItem.placeholders
    @State private var selectedGroup = 0
    @StateObject private var friends = FriendsViewModel()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.02, green: 0.03, blue: 0.07).ignoresSafeArea()
                VStack(spacing: 0) {
                    Color.clear.frame(height: max(proxy.safeAreaInsets.top, 44))
                    header
                    ScrollView(showsIndicators: false) {
                        if selectedGroup == 1 {
                            LazyVStack(spacing: 0) {
                                if let message = friends.error { Text(message).foregroundStyle(.red).padding() }
                                ForEach(friends.filtered(search)) { friend in
                                    NavigationLink { ChatView(friend: friend) } label: { friendRow(friend) }.buttonStyle(.plain)
                                }
                                if friends.items.isEmpty && friends.error == nil { Text("暂无好友").foregroundStyle(.white.opacity(0.6)).padding(.top, 50) }
                            }
                        } else {
                            LazyVStack(spacing: 0) { ForEach(filtered) { item in messageRow(item) } }
                        }
                    }.padding(.bottom, 120)
                }
            }
        }.navigationBarHidden(true).task { await friends.load() }
    }

    private var filtered: [MessageItem] { let source = messages.filter { $0.name != "好友消息" }; return search.isEmpty ? source : source.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.preview.localizedCaseInsensitiveContains(search) } }
    private var header: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(["消息", "好友"].indices, id: \.self) { i in
                    Button { selectedGroup = i } label: {
                        Text(["消息", "好友"][i]).font(.system(size: i == selectedGroup ? 18 : 16, weight: i == selectedGroup ? .bold : .regular)).foregroundStyle(i == selectedGroup ? .white : .white.opacity(0.55)).padding(.horizontal, 12).padding(.vertical, 10).overlay(alignment: .bottom) { if i == selectedGroup { Color(red: 0.95, green: 0.80, blue: 0.38).frame(height: 2) } }
                    }
                }
            }
            Spacer(minLength: 8)
            HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField(selectedGroup == 1 ? "搜索好友" : "搜索消息", text: $search).foregroundStyle(.primary).tint(.primary) }.padding(.horizontal, 12).frame(width: 150, height: 34).background(Color.white.opacity(0.10)).clipShape(Capsule())
        }.padding(.horizontal, 18).padding(.top, 12).padding(.bottom, 4)
    }
    private func messageRow(_ item: MessageItem) -> some View { Button { } label: { HStack(spacing: 12) { Circle().fill(item.color).frame(width: 54, height: 54).overlay(Image(systemName: item.icon).foregroundStyle(.white).font(.system(size: 22))); VStack(alignment: .leading, spacing: 6) { HStack { Text(item.name).font(.system(size: 17, weight: .medium)).foregroundStyle(.white); Spacer(); Text(item.time).font(.caption).foregroundStyle(.white.opacity(0.48)) }; Text(item.preview).font(.system(size: 14)).foregroundStyle(.white.opacity(0.58)).lineLimit(1) }; Spacer() }.padding(.horizontal, 20).frame(height: 82).overlay(alignment: .bottom) { Color.white.opacity(0.08).frame(height: 1).padding(.leading, 86) } }.buttonStyle(.plain) }
    private func friendRow(_ friend: FriendItem) -> some View { HStack(spacing: 12) { RemoteAvatar(urlString: friend.headPortrait, size: 54); VStack(alignment: .leading, spacing: 6) { Text(friend.nickName ?? "用户").font(.system(size: 17, weight: .medium)).foregroundStyle(.white) }; Spacer() }.padding(.horizontal, 20).frame(height: 82).contentShape(Rectangle()).overlay(alignment: .bottom) { Color.white.opacity(0.08).frame(height: 1).padding(.leading, 86) } }
}

struct FriendItem: Codable, Identifiable { let id: Int; let headPortrait: String?; let nickName: String?; let city: String?; let followStatus: String? }

@MainActor final class FriendsViewModel: ObservableObject {
    @Published var items: [FriendItem] = []
    @Published var error: String?
    func load() async {
        do { let r: APIEnvelope<PageResult<FriendItem>> = try await APIClient.shared.request(path: "community/fruser/friend/page", method: "GET", body: DiscoveryQuery(pageIndex: 1, pageSize: 100)); guard r.code == 200 else { throw APIError(statusCode: r.code, message: r.msg ?? "好友列表加载失败") }; items = r.data?.rows ?? []; error = nil }
        catch { let caught = error; self.error = caught.localizedDescription }
    }
    func filtered(_ search: String) -> [FriendItem] { search.isEmpty ? items : items.filter { ($0.nickName ?? "").localizedCaseInsensitiveContains(search) }
    }
}

struct ChatView: View {
    let friend: FriendItem
    @State private var text = ""
    @State private var messages: [ChatMessage] = []
    var body: some View {
        VStack(spacing: 0) {
            ScrollView { LazyVStack(alignment: .leading, spacing: 12) { ForEach(messages) { message in Text(message.text).foregroundStyle(.white).padding(10).background(Color.white.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 12)).frame(maxWidth: .infinity, alignment: message.mine ? .trailing : .leading) } }.padding() }
            HStack { TextField("输入消息", text: $text).textFieldStyle(.roundedBorder); Button("发送") { let value = text.trimmingCharacters(in: .whitespacesAndNewlines); guard !value.isEmpty else { return }; messages.append(ChatMessage(text: value, mine: true)); text = "" } }.padding()
        }.background(Color(red: 0.02, green: 0.03, blue: 0.07).ignoresSafeArea()).navigationTitle(friend.nickName ?? "聊天").navigationBarTitleDisplayMode(.inline)
    }
}
struct ChatMessage: Identifiable { let id = UUID(); let text: String; let mine: Bool }
struct MessageItem: Identifiable { let id = UUID(); let name: String; let preview: String; let time: String; let icon: String; let color: Color; static let placeholders = [MessageItem(name: "系统消息", preview: "欢迎来到谈笑", time: "刚刚", icon: "bell.fill", color: .purple), MessageItem(name: "匹配消息", preview: "等待新的匹配消息", time: "昨天", icon: "waveform", color: .blue)] }
