import SwiftUI

struct TwinFootstepsIcon: View {
    var body: some View {
        ZStack {
            Capsule().stroke(Color.white, lineWidth: 2.2).frame(width: 12, height: 24).rotationEffect(.degrees(-28)).offset(x: -5, y: -2)
            Capsule().stroke(Color.white, lineWidth: 2.2).frame(width: 12, height: 24).rotationEffect(.degrees(28)).offset(x: 5, y: 2)
        }.frame(width: 42, height: 42)
    }
}
