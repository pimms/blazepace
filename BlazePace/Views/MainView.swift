import SwiftUI

struct MainView: View {
    var body: some View {
        GeometryReader { geo in
            let _ = print("JDBG \(geo.size.width) \(WKInterfaceDevice.current().name)")
            ScrollView {
                VStack {
                    Text("🔥BlazePace🔥")
                        .lineLimit(1)
                        .font(.title3)
                        .allowsTightening(true)
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
