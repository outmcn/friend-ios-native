import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Text("星空").tabItem { Label("星空", systemImage: "sparkles") }
            DiscoveryView().tabItem { Label("发现", systemImage: "person.2") }
            Text("消息").tabItem { Label("消息", systemImage: "message") }
            Text("我的").tabItem { Label("我的", systemImage: "person") }
        }
        .navigationBarBackButtonHidden(true)
    }
}
