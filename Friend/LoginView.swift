import SwiftUI

struct LoginView: View {
    @StateObject private var model = AuthViewModel()
    @State private var showHome = false
    @State private var showRegister = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right.fill").font(.system(size: 64)).foregroundStyle(.blue)
            Text("谈笑").font(.largeTitle.bold())
            TextField("账号", text: $model.username).textInputAutocapitalization(.never).autocorrectionDisabled().textFieldStyle(.roundedBorder)
            SecureField("密码", text: $model.password).textFieldStyle(.roundedBorder)
            if let error = model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).multilineTextAlignment(.center) }
            Button { Task { await model.login(); if model.isLoggedIn { showHome = true } } } label: {
                Group { if model.isLoading { ProgressView() } else { Text("登录") } }.frame(maxWidth: .infinity).padding()
            }.buttonStyle(.borderedProminent)
            Button("注册账号") { showRegister = true }.foregroundStyle(.blue)
            Spacer()
        }
        .padding(24).navigationTitle("登录")
        .background(NavigationLink(destination: HomeView(), isActive: $showHome) { EmptyView() })
        .sheet(isPresented: $showRegister) { NavigationView { RegisterView() } }
    }
}
