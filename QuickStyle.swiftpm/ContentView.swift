import SwiftUI

struct ContentView: View {
    var wardrobeName: String
    var body: some View {
            TabView {
                WardrobeView(wardrobeName: wardrobeName)
                    .tabItem {
                        Label("My Wardrobe", systemImage: "hanger")
                            .foregroundColor(.black)
                    }
                PlanAndPackView()
                    .tabItem {
                        Label("Plan & Pack", systemImage: "suitcase.rolling.fill")
                    }
            }
    }
}
