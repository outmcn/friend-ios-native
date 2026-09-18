import Foundation
import SwiftUI

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published var users: [DiscoveryUser] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: APIEnvelope<[DiscoveryUser]> = try await APIClient.shared.request(path: "community/fruser/dynamic/user", method: "GET", body: EmptyBody())
            users = response.data ?? []
        } catch { errorMessage = error.localizedDescription }
    }
}

struct DiscoveryView: View {
    @StateObject private var model = DiscoveryViewModel()
    var body: some View {
        NavigationView {
            Group {
                if model.isLoading { ProgressView() }
                else if let error = model.errorMessage { Text(error).foregroundStyle(.red) }
                else { List(model.users) { user in Text(user.nickName ?? "用户") } }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task { await model.load() }
        }
    }
}
