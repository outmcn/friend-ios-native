import SwiftUI

struct VideoMatchingSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 22) {
                Image(systemName: "video.fill").font(.system(size: 58)).foregroundStyle(.blue)
                Text("视频匹配").font(.title2.bold())
                Text("选择匹配方式，寻找与你有共鸣的人。").multilineTextAlignment(.center).foregroundStyle(.secondary)
                Button("加速匹配") { dismiss() }.buttonStyle(.borderedProminent)
                Button("普通匹配") { dismiss() }.buttonStyle(.bordered)
            }.padding().navigationTitle("视频匹配").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("取消") { dismiss() } } }
        }
    }
}
