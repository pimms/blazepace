import Foundation
import SwiftUI

struct RootView: View {
    @State var navigation: [Navigation] = []

    var body: some View {
        NavigationStack(path: $navigation) {
            contentView
                .navigationDestination(for: Navigation.self) { navigation in
                    switch navigation {
                    case .setup:
                        SetupView()
                    }
                }
        }
    }

    var contentView: some View {
        MainView()
    }
}

struct RootViewPreview: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
