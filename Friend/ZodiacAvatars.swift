import SwiftUI

struct ZodiacAvatar: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let colors: [Color]
}

let zodiacAvatars: [ZodiacAvatar] = [
    .init(id: "rat", name: "鼠", symbol: "🐭", colors: [.indigo, .blue]), .init(id: "ox", name: "牛", symbol: "🐮", colors: [.brown, .orange]), .init(id: "tiger", name: "虎", symbol: "🐯", colors: [.orange, .red]), .init(id: "rabbit", name: "兔", symbol: "🐰", colors: [.pink, .purple]), .init(id: "dragon", name: "龙", symbol: "🐲", colors: [.green, .teal]), .init(id: "snake", name: "蛇", symbol: "🐍", colors: [.mint, .green]), .init(id: "horse", name: "马", symbol: "🐴", colors: [.brown, .red]), .init(id: "goat", name: "羊", symbol: "🐑", colors: [.gray, .blue]), .init(id: "monkey", name: "猴", symbol: "🐵", colors: [.orange, .brown]), .init(id: "rooster", name: "鸡", symbol: "🐔", colors: [.red, .yellow]), .init(id: "dog", name: "狗", symbol: "🐶", colors: [.blue, .purple]), .init(id: "pig", name: "猪", symbol: "🐷", colors: [.pink, .orange])
]

struct ZodiacAvatarGrid: View {
    @Binding var selected: String
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(zodiacAvatars) { avatar in
                Button { selected = avatar.id } label: {
                    VStack(spacing: 5) {
                        Image("zodiac_\(avatar.id)").resizable().interpolation(.none).scaledToFill().frame(width: 74, height: 74).clipShape(RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(selected == avatar.id ? Color.accentColor : .clear, lineWidth: 3))
                        Text(avatar.name).font(.caption).foregroundStyle(.primary)
                    }
                }.buttonStyle(.plain)
            }
        }
    }
}
