import Foundation
import SwiftUI

struct SpinnerView: View {
    let text: String?

    @State var isAnimating = false
    @State var progress: CGFloat = 0.2

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0), anchor: .center)
                .foregroundColor(.green)
                .animation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
            Text(text ?? "")
        }
        .frame(width: 120, height: 120)
        .onAppear {
            self.isAnimating = true
            withAnimation(Animation.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                progress = 0.9
            }
        }
    }
}

struct SpinnerViewPreviews: PreviewProvider {
    static var previews: some View {
        SpinnerView(text: "starting")
        SpinnerView(text: nil)
    }
}
