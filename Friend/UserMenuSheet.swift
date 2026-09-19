import SwiftUI

struct UserMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "sparkles").font(.system(size: 58)).foregroundStyle(.yellow)
                Text("我的").font(.title2.bold())
                Text("更多个人功能即将开放。\n设置入口后续补充。")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("知道了") { dismiss() }.buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
