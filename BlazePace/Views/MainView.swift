import SwiftUI

struct MainView: View {
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("icon-small")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(999, corners: .allCorners)
                    Spacer(minLength: 10)
                    NavigationLink("Start", value: Navigation.setup)
                        .background(Color.green.cornerRadius(8))
                        .foregroundColor(.black)
                    NavigationLink("Settings", value: Navigation.settings)
                        .background(Color.secondary.cornerRadius(8))
                        .foregroundColor(.black)
                    #if DEBUG
                    NavigationLink("Debug", value: Navigation.debug)
                        .background(Color.secondary.cornerRadius(8))
                        .foregroundColor(.black)
                    #endif
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
