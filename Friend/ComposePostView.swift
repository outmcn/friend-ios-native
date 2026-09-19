import SwiftUI

struct ComposePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $text).frame(minHeight: 150).padding(8).background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(alignment: .topLeading) { if text.isEmpty { Text("分享此刻的想法...").foregroundStyle(.secondary).padding(14).allowsHitTesting(false) } }
                if let image = selectedImage { Image(uiImage: image).resizable().scaledToFill().frame(height: 180).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 12)) }
                HStack { Button { showPicker = true } label: { Label("添加图片", systemImage: "photo") }; Spacer(); Text("\(text.count)/500").font(.footnote).foregroundStyle(.secondary) }.foregroundStyle(.blue)
                Spacer()
            }.padding().navigationTitle("发一条").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } }; ToolbarItem(placement: .navigationBarTrailing) { Button("发布") { dismiss() }.fontWeight(.bold).disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil) } }.sheet(isPresented: $showPicker) { ImagePicker(data: Binding(get: { selectedImage?.jpegData(compressionQuality: 0.85) }, set: { if let data = $0 { selectedImage = UIImage(data: data) } })) }
        }
    }
}
