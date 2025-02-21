import SwiftUI

struct LaunchScreenView: View {
    @State private var wardrobeName: String = ""
    @State private var isShowingMainApp = false // To control navigation
    @State private var showValidationAlert = false // To show validation feedback
    
    @EnvironmentObject private var wardrobeData: WardrobeData
    
    var body: some View {
        NavigationStack {
            VStack {
                // App Logo
                Image(systemName: "tshirt.fill") // Replace with your app logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)
                
                Spacer()
                
                // Gender Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("What is your gender?")
                        .font(.headline)
                    Picker("Gender", selection: $wardrobeData.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Wardrobe Name Question
                VStack(alignment: .leading, spacing: 10) {
                    Text("What is your wardrobe name?")
                        .font(.headline)
                    TextField("e.g., My Wardrobe", text: $wardrobeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    if wardrobeName.isEmpty {
                        showValidationAlert = true // Show alert if wardrobe name is empty
                    } else {
                        isShowingMainApp = true // Navigate to the main app
                    }
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Welcome") // Set the navigation title
            .alert(isPresented: $showValidationAlert) {
                Alert(
                    title: Text("Missing Information"),
                    message: Text("Please enter a wardrobe name to continue."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $isShowingMainApp) {
                ContentView(wardrobeName: wardrobeName)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
