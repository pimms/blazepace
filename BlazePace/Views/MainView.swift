import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("🔥BlazePace🔥")
                .font(.title2)
                .allowsTightening(true)
            NavigationLink("Start", value: Navigation.setup)
                .background(Color.green.cornerRadius(8))
                .foregroundColor(.black)
            NavigationLink("Settings", value: Navigation.settings)
                .background(Color.secondary.cornerRadius(8))
                .foregroundColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
