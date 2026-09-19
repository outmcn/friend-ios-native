import SwiftUI

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    var onPublished: (() -> Void)?
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
    }
    private func upload(_ image: UIImage) async throws -> String { guard let data = image.jpegData(compressionQuality: 0.85) else { throw APIError(statusCode: nil, message: "图片压缩失败") }; let result = try await APIClient.shared.uploadFile(data: data, filename: "dynamic-\(UUID().uuidString).jpg", mimeType: "image/jpeg"); guard let url = result.data?.url else { throw APIError(statusCode: result.code, message: result.msg ?? "图片上传失败") }; return url }
    private func publish() async { isPublishing = true; publishError = nil; do { let imageURL: String? = if let image = selectedImage { try await upload(image) } else { nil }; let body = BlogSubmitRequest(content: text.isEmpty ? nil : text, images: imageURL.map { [$0] }, lon: nil, lat: nil, city: LocationRefreshService.shared.cachedCity); let response: APIEnvelope<EmptyResponse> = try await APIClient.shared.request(path: "community/frblog/submit", method: "POST", body: body); guard response.code == 200 else { throw APIError(statusCode: response.code, message: response.msg ?? "发布失败") }; onPublished?(); dismiss() } catch { publishError = error.localizedDescription }; isPublishing = false }
}
