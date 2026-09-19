import SwiftUI

struct TwinFootstepsIcon: View {
    var body: some View {
        ZStack {
            FootprintShape(scale: 0.82)
                .fill(Color.white)
                .frame(width: 18, height: 25)
                .rotationEffect(.degrees(-18))
                .offset(x: -6, y: -4)
            FootprintShape(scale: 0.68)
                .fill(Color.white.opacity(0.9))
                .frame(width: 16, height: 22)
                .rotationEffect(.degrees(-18))
                .offset(x: 7, y: 5)
        }
        .frame(width: 46, height: 46)
    }
}

private struct FootprintShape: Shape {
    let scale: CGFloat
    func path(in rect: CGRect) -> Path {
        let w = rect.width * scale, h = rect.height * scale
        let x = (rect.width - w) / 2, y = (rect.height - h) / 2
        var p = Path()
        p.move(to: CGPoint(x: x + w * 0.48, y: y + h * 0.03))
        p.addCurve(to: CGPoint(x: x + w * 0.82, y: y + h * 0.28), control1: CGPoint(x: x + w * 0.78, y: y - h * 0.02), control2: CGPoint(x: x + w * 0.98, y: y + h * 0.12))
        p.addCurve(to: CGPoint(x: x + w * 0.75, y: y + h * 0.82), control1: CGPoint(x: x + w * 0.72, y: y + h * 0.43), control2: CGPoint(x: x + w * 0.91, y: y + h * 0.63))
        p.addCurve(to: CGPoint(x: x + w * 0.28, y: y + h * 0.96), control1: CGPoint(x: x + w * 0.58, y: y + h * 1.03), control2: CGPoint(x: x + w * 0.18, y: y + h * 1.02))
        p.addCurve(to: CGPoint(x: x + w * 0.18, y: y + h * 0.52), control1: CGPoint(x: x + w * 0.02, y: y + h * 0.82), control2: CGPoint(x: x + w * 0.12, y: y + h * 0.60))
        p.addCurve(to: CGPoint(x: x + w * 0.48, y: y + h * 0.03), control1: CGPoint(x: x + w * 0.22, y: y + h * 0.28), control2: CGPoint(x: x + w * 0.30, y: y + h * 0.08))
        return p
    }
}
