import SwiftUI

struct AvatarActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let info: PersonalCenter
    @State private var selectedTab = 0
    @State private var logoutPending = false
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    tab("资料", 0)
                    tab("设置", 1)
                }
                .background(Color(.secondarySystemBackground))
                if selectedTab == 0 {
                    ProfileEditorSheet(info: info).id("profile")
                } else {
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
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private func tab(_ title: String, _ index: Int) -> some View {
        Button { selectedTab = index } label: {
            Text(title).font(.system(size: 16, weight: selectedTab == index ? .bold : .regular))
                .foregroundStyle(selectedTab == index ? .primary : .secondary)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .overlay(alignment: .bottom) { if selectedTab == index { Color.accentColor.frame(height: 2) } }
        }
    }
}
