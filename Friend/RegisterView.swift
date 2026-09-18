import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = RegisterViewModel()
    @State private var showImagePicker = false
    @State private var showHome = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white.ignoresSafeArea()
                Image("FriendLoginLoginBackground").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Color.clear.frame(height: 32)
                        if model.stage == 1 { stageOne } else { stageTwo }
                        if let error = model.errorMessage { Text(error).foregroundStyle(.red).font(.footnote).multilineTextAlignment(.center) }
                        Button("已有账号？立即登录") { dismiss() }.foregroundStyle(Color(red:0.40,green:0.42,blue:0.60)).padding(.top, 25)
                    }.padding(.horizontal, 38).padding(.bottom, proxy.safeAreaInsets.bottom + 30)
                }
            }
        }.navigationBarHidden(true).background(NavigationLink(destination: HomeView(), isActive: $showHome) { EmptyView() }).sheet(isPresented: $showImagePicker) { ImagePicker(data: $model.avatarData) }
    }
    private var stageOne: some View { VStack(spacing: 16) { registerField("手机号", text: $model.phone, keyboard: .phonePad); registerField("验证码", text: $model.code, keyboard: .numberPad); Button("下一步") { Task { await model.verifyCode() } }.buttonStyle(.borderedProminent).tint(Color(red:0.31,green:0.33,blue:0.53)).frame(maxWidth:.infinity).padding(.top,20) } }
    private var stageTwo: some View { VStack(spacing: 16) { HStack(spacing: 20) { gender("男生", "FriendLoginAvataman", "male"); gender("女生", "FriendLoginAvatarwoman", "female") }.padding(.bottom, 20); Button { showImagePicker = true } label: { ZStack { Circle().fill(Color.white); if model.avatarData == nil { Image("FriendLoginCamera").resizable().scaledToFit().frame(width:55,height:55); Image("FriendLoginAddCamera").resizable().frame(width:30,height:30).offset(y:38) } else { Image(uiImage: UIImage(data:model.avatarData!)!).resizable().scaledToFill() } }.frame(width:120,height:120).clipShape(Circle()) }; registerField("昵称", text: $model.nickname); registerField("生日", text: $model.birthday); registerField("所在城市", text: $model.city); secureField("登录密码", text: $model.password); secureField("确认密码", text: $model.confirmPassword); Button { Task { if await model.register() { showHome = true } } } label: { Text(model.isLoading ? "注册中…" : "完成注册").frame(maxWidth:.infinity).frame(height:44) }.buttonStyle(.borderedProminent).tint(Color(red:0.31,green:0.33,blue:0.53)).padding(.top,20) } }
    private func registerField(_ label:String,text:Binding<String>,keyboard:UIKeyboardType = .default)->some View { HStack { Text(label).font(.system(size:15,weight:.bold)).foregroundStyle(Color(red:0.31,green:0.33,blue:0.53)).frame(width:70,alignment:.leading); TextField("请输入",text:text).keyboardType(keyboard) }.padding(.horizontal,18).frame(height:44).background(Color.white.opacity(0.92)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.31,green:0.33,blue:0.53),lineWidth:1)) }
    private func secureField(_ label:String,text:Binding<String>)->some View { HStack { Text(label).font(.system(size:15,weight:.bold)).foregroundStyle(Color(red:0.31,green:0.33,blue:0.53)).frame(width:70,alignment:.leading); SecureField("请输入",text:text) }.padding(.horizontal,18).frame(height:44).background(Color.white.opacity(0.92)).clipShape(Capsule()).overlay(Capsule().stroke(Color(red:0.31,green:0.33,blue:0.53),lineWidth:1)) }
    private func gender(_ title:String,_ image:String,_ value:String)->some View { Button { model.gender=value } label: { VStack { Image(image).resizable().scaledToFit().frame(height:55); Text(title).foregroundStyle(.black) }.frame(width:130,height:115).background(model.gender==value ? Color.white : Color.white.opacity(0.65)).clipShape(RoundedRectangle(cornerRadius:18)).overlay(RoundedRectangle(cornerRadius:18).stroke(model.gender==value ? Color(red:0.31,green:0.33,blue:0.53):.clear,lineWidth:2)) } }
}
