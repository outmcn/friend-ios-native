import SwiftUI

struct CommentActionSheet: View {
    let onCopy: () -> Void
    let onReport: () -> Void
    let onDelete: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            Button("复制", action: onCopy).padding()
            Divider()
            Button("举报", action: onReport).padding()
            Divider()
            Button("删除", role: .destructive, action: onDelete).padding()
            Divider()
            Button("取消") {}.padding()
        }
    }
}
