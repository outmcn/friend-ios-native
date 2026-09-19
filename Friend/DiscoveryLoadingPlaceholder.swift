import SwiftUI

struct DiscoveryLoadingPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Circle().fill(Color.white.opacity(0.22)).frame(width: 40, height: 40)
                RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.18)).frame(width: 92, height: 14)
            }
            RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.16)).frame(width: 190, height: 16)
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [Color(red: 0.16, green: 0.26, blue: 0.50), Color(red: 0.90, green: 0.47, blue: 0.28)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 150)
                .overlay(ProgressView().tint(.white))
            HStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.16)).frame(width: 54, height: 13)
                RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.16)).frame(width: 54, height: 13)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .redacted(reason: .placeholder)
    }
}
