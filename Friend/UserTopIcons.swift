import SwiftUI

struct TwinFootstepsIcon: View {
    var body: some View {
        ZStack {
            FootShape().fill(Color.white).frame(width: 15, height: 24).rotationEffect(.degrees(-20)).offset(x: -6, y: -4)
            FootShape().fill(Color.white.opacity(0.88)).frame(width: 13, height: 21).rotationEffect(.degrees(-20)).offset(x: 7, y: 5)
        }.frame(width: 42, height: 42)
    }
}

private struct FootShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.48, y: 0))
        p.addCurve(to: CGPoint(x: w * 0.84, y: h * 0.36), control1: CGPoint(x: w * 0.83, y: -h * 0.04), control2: CGPoint(x: w * 1.02, y: h * 0.13))
        p.addCurve(to: CGPoint(x: w * 0.73, y: h * 0.84), control1: CGPoint(x: w * 0.76, y: h * 0.48), control2: CGPoint(x: w * 0.94, y: h * 0.68))
        p.addCurve(to: CGPoint(x: w * 0.26, y: h), control1: CGPoint(x: w * 0.58, y: h * 1.06), control2: CGPoint(x: w * 0.10, y: h * 1.02))
        p.addCurve(to: CGPoint(x: w * 0.18, y: h * 0.48), control1: CGPoint(x: w * 0.01, y: h * 0.82), control2: CGPoint(x: w * 0.12, y: h * 0.61))
        p.addCurve(to: CGPoint(x: w * 0.48, y: 0), control1: CGPoint(x: w * 0.20, y: h * 0.28), control2: CGPoint(x: w * 0.26, y: h * 0.06))
        return p
    }
}

struct ScanCodeIcon: View {
    var body: some View {
        ZStack {
            ScanCorners().stroke(Color.white, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
            Image(systemName: "qrcode").font(.system(size: 17, weight: .medium)).foregroundStyle(.white)
        }.frame(width: 42, height: 42)
    }
}

private struct ScanCorners: Shape {
    func path(in rect: CGRect) -> Path {
        let x = rect.minX + 4, y = rect.minY + 4, r = rect.maxX - 4, b = rect.maxY - 4, l: CGFloat = 9
        var p = Path()
        p.move(to: CGPoint(x: x + l, y: y)); p.addLine(to: CGPoint(x: x, y: y)); p.addLine(to: CGPoint(x: x, y: y + l))
        p.move(to: CGPoint(x: r - l, y: y)); p.addLine(to: CGPoint(x: r, y: y)); p.addLine(to: CGPoint(x: r, y: y + l))
        p.move(to: CGPoint(x: x, y: b - l)); p.addLine(to: CGPoint(x: x, y: b)); p.addLine(to: CGPoint(x: x + l, y: b))
        p.move(to: CGPoint(x: r - l, y: b)); p.addLine(to: CGPoint(x: r, y: b)); p.addLine(to: CGPoint(x: r, y: b - l))
        return p
    }
}

struct MenuLinesIcon: View {
    var body: some View {
        VStack(spacing: 5) { ForEach(0..<3, id: \.self) { _ in Capsule().fill(Color.white).frame(width: 25, height: 2.5) } }.frame(width: 42, height: 42)
    }
}
