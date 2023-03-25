import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            NavigationLink("Setup", value: Navigation.setup)
            NavigationLink("Settings", value: Navigation.settings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
