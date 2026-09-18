import SwiftUI

struct ProfileActionIcon: View {
    enum Kind { case pencil, footprints, addPerson, menu }
    let kind: Kind
    var body: some View {
        Canvas { context, size in
            let color = Color(white: 0.96)
            var path = Path()
            switch kind {
            case .pencil:
                path.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.80)); path.addLine(to: CGPoint(x: size.width * 0.72, y: size.height * 0.26)); path.move(to: CGPoint(x: size.width * 0.16, y: size.height * 0.82)); path.addLine(to: CGPoint(x: size.width * 0.34, y: size.height * 0.76)); path.move(to: CGPoint(x: size.width * 0.66, y: size.height * 0.20)); path.addLine(to: CGPoint(x: size.width * 0.80, y: size.height * 0.34))
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: size.width * 0.10, lineCap: .round, lineJoin: .round))
            case .footprints:
                let r = size.width * 0.17
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.18, y: size.height * 0.50, width: r, height: size.height * 0.34)), with: .color(color))
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.55, y: size.height * 0.16, width: r, height: size.height * 0.34)), with: .color(color))
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.12, y: size.height * 0.26, width: r * 0.45, height: r * 0.45)), with: .color(color))
                context.fill(Path(ellipseIn: CGRect(x: size.width * 0.73, y: size.height * 0.02, width: r * 0.45, height: r * 0.45)), with: .color(color))
            case .addPerson:
                context.stroke(Path(ellipseIn: CGRect(x: size.width * 0.12, y: size.height * 0.08, width: size.width * 0.34, height: size.width * 0.34)), with: .color(color), style: StrokeStyle(lineWidth: size.width * 0.08))
                var shoulders = Path(); shoulders.move(to: CGPoint(x: size.width * 0.04, y: size.height * 0.88)); shoulders.addCurve(to: CGPoint(x: size.width * 0.54, y: size.height * 0.88), control1: CGPoint(x: size.width * 0.10, y: size.height * 0.55), control2: CGPoint(x: size.width * 0.46, y: size.height * 0.55)); context.stroke(shoulders, with: .color(color), style: StrokeStyle(lineWidth: size.width * 0.08, lineCap: .round))
                var plus = Path(); plus.move(to: CGPoint(x: size.width * 0.76, y: size.height * 0.48)); plus.addLine(to: CGPoint(x: size.width * 0.76, y: size.height * 0.90)); plus.move(to: CGPoint(x: size.width * 0.56, y: size.height * 0.69)); plus.addLine(to: CGPoint(x: size.width * 0.96, y: size.height * 0.69)); context.stroke(plus, with: .color(color), style: StrokeStyle(lineWidth: size.width * 0.08, lineCap: .round))
            case .menu:
                for y in [0.25, 0.50, 0.75] { var line = Path(); line.move(to: CGPoint(x: size.width * 0.08, y: size.height * y)); line.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * y)); context.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: size.height * 0.12, lineCap: .round)) }
            }
        }
        .accessibilityHidden(true)
    }
}
