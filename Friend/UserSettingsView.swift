import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logoutPending = false
    var body: some View {
        List {
            Section("账户") {
                NavigationLink("隐私设置") { PrivacyView() }
                NavigationLink("账户充值") { RechargeView() }
            }
            Section {
                Button("退出登录", role: .destructive) { logoutPending = true }
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("确定退出登录吗？", isPresented: $logoutPending) {
            Button("退出登录", role: .destructive) {
                TokenStore.shared.clear()
                UserDefaults.standard.removeObject(forKey: "friend.user.center.cache")
                dismiss()
            }
        }
    }
}
