import SwiftUI

struct MyDynamicsView: View {
    @StateObject private var model = MyDynamicsViewModel()
    var body: some View {
        ZStack { Color(.systemGroupedBackground).ignoresSafeArea(); ScrollView { LazyVStack(spacing: 14) { ForEach(model.items) { item in blogCard(item) } } .padding() } }
        .navigationTitle("我的动态").navigationBarTitleDisplayMode(.inline)
        .task { await model.load() }
        .refreshable { await model.load() }
    }
    private func blogCard(_ item: BlogPageResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { RemoteAvatar(urlString: item.headPortrait, size: 42); VStack(alignment: .leading) { Text(item.nickName ?? "管理员").font(.headline); Text(item.pushTime ?? "").font(.caption).foregroundStyle(.secondary) }; Spacer() }
            if let content = item.content, !content.isEmpty { Text(content).font(.body) }
            if let images = item.images, !images.isEmpty { Text("图片动态").font(.footnote).foregroundStyle(.secondary) }
            HStack { Label("\(item.fabulous ?? 0)", systemImage: "heart"); Label("\(item.comment ?? 0)", systemImage: "message") }.font(.footnote).foregroundStyle(.secondary)
        }.padding().background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

@MainActor final class MyDynamicsViewModel: ObservableObject {
    @Published var items: [BlogPageResponse] = []
    func load() async { do { let r: APIEnvelope<PageResult<BlogPageResponse>> = try await APIClient.shared.request(path: "community/frblog/mine/blog/page", method: "GET", body: PageQuery()); items = r.data?.rows ?? [] } catch { items = [] } }
}
struct PageQuery: Encodable { let pageIndex = 1; let pageSize = 20 }
