import SwiftUI

struct ProfileEditorSheet: View {
    let info: PersonalCenter
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String
    @State private var selectedAvatar: String
    @State private var error: String?
    @State private var saving = false
    init(info: PersonalCenter) { self.info = info; _nickname = State(initialValue: info.nickName ?? ""); _selectedAvatar = State(initialValue: info.headPortrait ?? "zodiac_dog") }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("选择生肖头像").font(.headline)
                    ZodiacAvatarGrid(selected: $selectedAvatar)
                    TextField("昵称", text: $nickname).textFieldStyle(.roundedBorder)
                    if let error { Text(error).foregroundStyle(.red) }
                    Button(saving ? "保存中…" : "保存") { Task { await save() } }.frame(maxWidth: .infinity).buttonStyle(.borderedProminent).disabled(saving || nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }.padding()
            }
            .navigationTitle("编辑资料").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } } }
        }
    }
    private func save() async {
        saving = true; error = nil
        do {
            let body = EditPersonalRequest(id: info.id ?? 0, headPortrait: selectedAvatar, nickName: nickname.trimmingCharacters(in: .whitespacesAndNewlines))
            let r: APIEnvelope<EmptyResponse> = try await APIClient.shared.request(path: "community/fruser/edit/personal", method: "PUT", body: body)
            guard r.code == 200 else { throw APIError(statusCode: r.code, message: r.msg ?? "保存失败") }
            let updated = ProfileUpdate(id: info.id ?? 0, nickName: body.nickName, headPortrait: body.headPortrait)
            UserDefaults.standard.removeObject(forKey: "friend.user.center.cache")
            NotificationCenter.default.post(name: .profileUpdated, object: updated)
            dismiss()
        } catch { self.error = error.localizedDescription }
        saving = false
    }
}
struct EditPersonalRequest: Encodable { let id: Int; let headPortrait: String; let nickName: String }
