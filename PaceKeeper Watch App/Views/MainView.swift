import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationLink("Setup", value: Navigation.setup)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
