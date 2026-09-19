import SwiftUI

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var isPublishing = false
    @State private var publishError: String?
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $text).frame(minHeight: 150).padding(8).background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(alignment: .topLeading) { if text.isEmpty { Text("分享此刻的想法...").foregroundStyle(.secondary).padding(14).allowsHitTesting(false) } }
                if let image = selectedImage { Image(uiImage: image).resizable().scaledToFill().frame(height: 180).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 12)) }
                HStack { Button { showPicker = true } label: { Label("添加图片", systemImage: "photo") }; Spacer(); Text("\(text.count)/500").font(.footnote).foregroundStyle(.secondary) }.foregroundStyle(.blue)
                if let publishError { Text(publishError).font(.footnote).foregroundStyle(.red) }
                Spacer()
            }.padding().navigationTitle("发一条").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } }; ToolbarItem(placement: .navigationBarTrailing) { Button("发布") { Task { await publish() } }.font(.system(size: 16, weight: .bold)).disabled(isPublishing || (text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)) } }.sheet(isPresented: $showPicker) { ImagePicker(data: Binding(get: { selectedImage?.jpegData(compressionQuality: 0.85) }, set: { if let data = $0 { selectedImage = UIImage(data: data) } })) }
        }
    private func publish() async { isPublishing = true; publishError = nil; do { let body = BlogSubmitRequest(content: text.isEmpty ? nil : text, images: nil, lon: nil, lat: nil, city: LocationRefreshService.shared.cachedCity); let r: APIEnvelope<EmptyResponse> = try await APIClient.shared.request(path: "community/frblog/submit", method: "POST", body: body); guard r.code == 200 else { throw APIError(statusCode: r.code, message: r.msg ?? "发布失败") }; dismiss() } catch { publishError = error.localizedDescription }; isPublishing = false }
