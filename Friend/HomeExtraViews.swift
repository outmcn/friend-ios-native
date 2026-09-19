import SwiftUI

struct HomeSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var keyword = ""
    var body: some View { NavigationView { VStack(spacing: 18) { HStack { Image(systemName: "magnifyingglass").foregroundStyle(.secondary); TextField("搜索用户或内容", text: $keyword).foregroundStyle(.primary).tint(.primary) }.padding().background(Color(.secondarySystemBackground)).clipShape(Capsule()).padding(.horizontal); Text(keyword.isEmpty ? "输入关键词后搜索" : "暂无搜索结果").foregroundStyle(.secondary); Spacer() }.padding(.top, 20).navigationTitle("筛选").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("完成") { dismiss() } } } } }
}

struct StarInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationView { VStack(spacing: 20) { Image(systemName: "sparkles").font(.system(size: 58)).foregroundStyle(.yellow); Text("点缀星空").font(.title2.bold()); Text("用你的方式装点星空，更多功能即将开放。").multilineTextAlignment(.center).foregroundStyle(.secondary); Button("知道了") { dismiss() }.buttonStyle(.borderedProminent) }.padding().navigationTitle("星空").navigationBarTitleDisplayMode(.inline) } }
}
