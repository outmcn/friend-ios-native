import SwiftUI

struct LoginView: View {
    @StateObject private var model = AuthViewModel()
    @State private var showHome = false
    @State private var showRegister = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white.ignoresSafeArea()
                Image("FriendLoginLoginBackground").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom).ignoresSafeArea()
                VStack(spacing: 0) {
                    Spacer().frame(height: proxy.size.height * 0.16)
                    VStack(spacing: 0) {
                        loginField(label: "账号", text: $model.username, secure: false)
                        loginField(label: "密码", text: $model.password, secure: true)
                        if let error = model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).multilineTextAlignment(.center).padding(.top, 8) }
                        Button { Task { await model.login(); if model.isLoggedIn { showHome = true } } } label: { Group { if model.isLoading { ProgressView() } else { Text("登录") } }.frame(maxWidth: .infinity).frame(height: 40) }.buttonStyle(.borderedProminent).tint(Color(red:0.31,green:0.33,blue:0.53)).padding(.top, 24)
                    }.padding(.horizontal, 38)
                    Spacer()
                    Button("注册账号") { showRegister = true }.foregroundStyle(Color(red:0.40,green:0.42,blue:0.60)).padding(.bottom, proxy.safeAreaInsets.bottom + 28)
                }
            }
        }.navigationBarHidden(true).background(NavigationLink(destination: HomeView(), isActive: $showHome) { EmptyView() }).sheet(isPresented: $showRegister) { NavigationView { RegisterView() } }
    }
    private func loginField(label: String, text: Binding<String>, secure: Bool) -> some View {
        HStack(spacing: 12) { Text(label).font(.system(size: 15, weight: .bold)).foregroundStyle(Color(red:0.31,green:0.33,blue:0.53)).frame(width: 48, alignment: .leading); if secure { SecureField("请输入", text: text) } else { TextField("请输入", text: text).textInputAutocapitalization(.never).autocorrectionDisabled() } }.padding(.horizontal, 18).frame(height: 44).background(Color.white.opacity(0.92)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.31,green:0.33,blue:0.53),lineWidth: 1)).padding(.bottom, 16)
    }
}
