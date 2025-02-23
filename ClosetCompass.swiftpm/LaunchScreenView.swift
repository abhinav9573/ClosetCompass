import SwiftUI

struct LaunchScreenView: View {
    @State private var wardrobeName: String = "My Wardrobe"
    @State private var isShowingMainApp = false
    @State private var showValidationAlert = false
    
    @EnvironmentObject private var wardrobeData: WardrobeData
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if let uiImage = UIImage(named: "closet 1") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                            .padding(.top, 50)
                    } else {
                        Image(systemName: "tshirt.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, 50)
                    }
                Text("Your Personal Wardrobe Manager")
                                   .font(.title3)
                                   .fontWeight(.thin)
                                   .foregroundColor(.black)
                                   .multilineTextAlignment(.center)
                                   .padding(.top, 10)
                Spacer()
                
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

                VStack(alignment: .leading, spacing: 10) {
                    Text("What is your wardrobe name?")
                        .font(.headline)
                    TextField("e.g., My Wardrobe", text: $wardrobeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                

                Button(action: {
                    if wardrobeName.isEmpty {
                        showValidationAlert = true
                    } else {
                        isShowingMainApp = true 
                    }
                }) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Welcome to")
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
