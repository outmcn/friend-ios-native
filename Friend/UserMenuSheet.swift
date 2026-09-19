import SwiftUI

struct UserMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logoutPending = false
    var body: some View {
        NavigationView {
            List {
                Section("设置") {
                    NavigationLink("隐私设置") { PrivacyView() }
                    NavigationLink("账户充值") { RechargeView() }
                    Button("退出登录", role: .destructive) { logoutPending = true }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("确定退出登录吗？", isPresented: $logoutPending) {
                Button("退出登录", role: .destructive) { SessionStore.shared.logout(); dismiss() }
                Button("取消", role: .cancel) { }
            }
        }
    }
}
