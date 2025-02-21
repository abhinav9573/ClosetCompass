import SwiftUI
@main
struct MyApp: App {
    @StateObject private var wardrobeData = WardrobeData() // Create the environment object here

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(wardrobeData) // Provide the environment object at the root level
        }
    }
}
