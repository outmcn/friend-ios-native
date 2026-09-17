import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)
                Text("谈笑")
                    .font(.largeTitle.bold())
                Text("Friend 原生客户端")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("谈笑")
        }
    }
}

#Preview {
    RootView()
}
