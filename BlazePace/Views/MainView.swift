import SwiftUI

struct MainView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("🔥BlazePace🔥")
                    .lineLimit(1)
                    .font(.title2)
                    .allowsTightening(true)
                NavigationLink("Start", value: Navigation.setup)
                    .background(Color.green.cornerRadius(8))
                    .foregroundColor(.black)
                NavigationLink("Settings", value: Navigation.settings)
                    .background(Color.secondary.cornerRadius(8))
                    .foregroundColor(.black)
                NavigationLink("Debug", value: Navigation.debug)
                    .background(Color.secondary.cornerRadius(8))
                    .foregroundColor(.black)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
