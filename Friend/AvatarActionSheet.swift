import SwiftUI

struct AvatarActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let info: PersonalCenter
    @State private var selectedTab = 0
    @State private var logoutPending = false
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 0) { tab("资料", 0); tab("设置", 1) }.background(Color(.secondarySystemBackground))
                if selectedTab == 0 { profileContent } else { settingsContent }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("个人二维码").font(.headline)
                Image(systemName: "qrcode").interpolation(.none).resizable().scaledToFit().frame(width: 190, height: 190).padding(18).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
                Text(info.nickName ?? "用户").font(.title3.bold()).foregroundStyle(.primary)
                Text("扫一扫添加好友").font(.footnote).foregroundStyle(.secondary)
                Spacer(minLength: 20)
            }.frame(maxWidth: .infinity).padding(.top, 28)
        }
    }
    private var settingsContent: some View {
        List {
            Section("设置") {
                NavigationLink("隐私设置") { PrivacyView() }
                NavigationLink("账户充值") { RechargeView() }
                Button("退出登录", role: .destructive) { logoutPending = true }
            }
        }
        .confirmationDialog("确定退出登录吗？", isPresented: $logoutPending) {
            Button("退出登录", role: .destructive) { SessionStore.shared.logout(); dismiss() }
            Button("取消", role: .cancel) { }
        }
    }
    private func tab(_ title: String, _ index: Int) -> some View { Button { selectedTab = index } label: { Text(title).font(.system(size: 16, weight: selectedTab == index ? .bold : .regular)).foregroundStyle(selectedTab == index ? .primary : .secondary).frame(maxWidth: .infinity).padding(.vertical, 14).overlay(alignment: .bottom) { if selectedTab == index { Color.accentColor.frame(height: 2) } } } }
}
