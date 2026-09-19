import SwiftUI

struct FootstepsSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationView { VStack(spacing: 20) { Image(systemName: "figure.walk").font(.system(size: 58)).foregroundStyle(.blue); Text("脚步").font(.title2.bold()); Text("脚步功能即将开放").foregroundStyle(.secondary); Button("知道了") { dismiss() }.buttonStyle(.borderedProminent); Spacer() }.padding().navigationTitle("脚步").navigationBarTitleDisplayMode(.inline) } }
}

struct ScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View { NavigationView { VStack(spacing: 20) { Image(systemName: "qrcode.viewfinder").font(.system(size: 58)).foregroundStyle(.green); Text("扫码").font(.title2.bold()); Text("扫码功能即将开放").foregroundStyle(.secondary); Button("知道了") { dismiss() }.buttonStyle(.borderedProminent); Spacer() }.padding().navigationTitle("扫码").navigationBarTitleDisplayMode(.inline) } }
}
