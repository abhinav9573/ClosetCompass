import SwiftUI

struct ContentView: View {
    var body: some View {
//        TabView {
//            LookUpView()
//                .tabItem {
//                    Label("Look Up", systemImage: "camera.viewfinder")
//                }
            
            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "folder.fill")
                }
//        }
    }
}
