import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: { SetupView() }, label: {
                Text("Setup")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
