import SwiftUI
@main
struct MyApp: App {
    @StateObject private var wardrobeData = WardrobeData()

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(wardrobeData)
        }
    }
}
