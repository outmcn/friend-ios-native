import SwiftUI

struct ProfileEditorSheet: View {
    let info: PersonalCenter
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String
    @State private var error: String?
    @State private var saving = false
    init(info: PersonalCenter) { self.info = info; _nickname = State(initialValue: info.nickName ?? "") }
    var body: some View {
        NavigationView {
            Form {
                Section("个人资料") { TextField("昵称", text: $nickname) }
                if let error { Text(error).foregroundStyle(.red) }
                Button(saving ? "保存中…" : "保存") { Task { await save() } }.disabled(saving || nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.navigationTitle("编辑资料").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } } }
        }
    }
    private func save() async {
        saving = true; error = nil
        do {
            let body = EditPersonalRequest(id: info.id ?? 0, headPortrait: info.headPortrait ?? "", nickName: nickname.trimmingCharacters(in: .whitespacesAndNewlines))
            let r: APIEnvelope<EmptyResponse> = try await APIClient.shared.request(path: "community/fruser/edit/personal", method: "PUT", body: body)
            guard r.code == 200 else { throw APIError(statusCode: r.code, message: r.msg ?? "保存失败") }
            dismiss()
        } catch { error = error.localizedDescription }
        saving = false
    }
}

struct EditPersonalRequest: Encodable { let id: Int; let headPortrait: String; let nickName: String }
