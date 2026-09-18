import SwiftUI

struct HomeView: View {
    var body: some View {
        NativeHomeView()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}
