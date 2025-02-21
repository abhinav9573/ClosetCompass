import SwiftUI
import PhotosUI

struct WardrobeView: View {
    var wardrobeName: String
    @State private var selectedCategory: String = "Shirts"
    @State private var isSheetPresented = false
    @State private var selectedImage: UIImage?
    @State private var isAddCategoryPopupPresented = false // Controls the popup visibility
    @State private var newCategoryName: String = ""
    @State private var selectedImageForPopup: UIImage? = nil // For the image popup
    
    @EnvironmentObject private var wardrobeData: WardrobeData
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                VStack(alignment: .leading) {
                    
                    // **Category Buttons**
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // **Add Category Button (First in the List)**
                            Button(action: {
                                isAddCategoryPopupPresented.toggle() // Show the popup
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(20)
                            }
                            
                            // **Existing Categories**
                            ForEach(wardrobeData.categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.black : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCategory == category ? .white : .black)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                    }
                    
                    // **Category Title**
                    Text(selectedCategory)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading)
                        .padding(.top, 5)
                    
                    // **Wardrobe Grid**
                    let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
                    
                    ScrollView {
                        LazyVGrid(columns: gridLayout, spacing: 15) {
                            ForEach(wardrobeData.wardrobeItems[selectedCategory] ?? [], id: \.self) { image in
                                VStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 160, height: 160) // Fixed Frame Size
                                        .cornerRadius(10) // Adds spacing inside the card
                                        .onTapGesture {
                                            selectedImageForPopup = image // Show the popup
                                        }
                                }
                                .frame(width: 180, height: 180) // Card size
                                .background(Color.white) // Card background
                                .cornerRadius(13)
                                .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal,10)
                        .padding(.top, 10)
                    }
                    
                }
                .navigationTitle(wardrobeName)
                .navigationBarTitleDisplayMode(.large)
                .navigationBarBackButtonHidden(true) // Hide the back button
                
                // **Upload Button**
                .overlay(
                    Button(action: {
                        isSheetPresented.toggle()
                    }) {
                        Text("Upload Cloth Image")
                            .font(.system(size: 16, weight: .bold))
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                    }
                        .padding()
                    , alignment: .bottom
                )
                
                // **Bottom Sheet**
                .sheet(isPresented: $isSheetPresented) {
                    if #available(iOS 16.4, *) {
                        UploadClothesSheet(selectedCategory: selectedCategory)
                            .environmentObject(wardrobeData) // Pass the environment object
                            .presentationDetents([.fraction(0.35)]) // Show modal at ~35% height
                            .presentationCornerRadius(20)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                // **Popup for Adding New Category**
                if isAddCategoryPopupPresented {
                    // Semi-transparent background
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isAddCategoryPopupPresented = false // Dismiss popup on background tap
                        }
                    
                    // Popup Content
                    VStack {
                        Text("Add New Category")
                            .font(.headline)
                            .padding()
                        
                        TextField("Enter category name", text: $newCategoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        HStack {
                            Button("Cancel") {
                                isAddCategoryPopupPresented = false // Dismiss popup
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            
                            Button("Save") {
                                if !newCategoryName.isEmpty {
                                    wardrobeData.addCategory(newCategoryName)
                                    newCategoryName = ""
                                    isAddCategoryPopupPresented = false // Dismiss popup
                                }
                            }
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    .frame(width: 300)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .transition(.scale) // Add a transition effect
                }
                
                // **Popup for Displaying Selected Image**
                if let selectedImageForPopup = selectedImageForPopup {
                    ZStack {
                        // Semi-transparent background
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.selectedImageForPopup = nil // Dismiss the popup
                            }
                        
                        // Popup Content
                        VStack {
                            Image(uiImage: selectedImageForPopup)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(15)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                            
                            // Close Button
                            Button(action: {
                                self.selectedImageForPopup = nil // Dismiss the popup
                            }) {
                                Text("Close")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 10)
                        }
                        .frame(width: 300, height: 400) // Adjust the size of the popup
                    }
                    .transition(.opacity) // Add a smooth transition
                }
            }
        }
    }
}    // **Bottom Sheet View**
    struct UploadClothesSheet: View {
        var selectedCategory: String
        
        @EnvironmentObject private var wardrobeData: WardrobeData
        
        @State private var isImagePickerPresented = false
        @State private var isCameraPresented = false
        
        var body: some View {
            VStack {
                Text("Upload new clothes")
                    .font(.headline)
                    .padding(.top)
                
                HStack(spacing: 20) {
                    // **Take Photo Card**
                    Button(action: { isCameraPresented.toggle() }) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.3)) // Light green background
                                .frame(width: 160, height: 160)
                            
                            VStack(alignment: .leading) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black)
                                    .padding(10)
                                
                                Spacer()
                                
                                Text("Take Photo")
                                    .font(.callout)
                                    .foregroundColor(.black)
                                    .padding(10)
                            }
                            .frame(width: 160, height: 160, alignment: .leading)
                        }
                    }
                    
                    // **Upload Photo Card**
                    Button(action: { isImagePickerPresented.toggle() }) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.3)) // Light gray background
                                .frame(width: 160, height: 160)
                            
                            VStack(alignment: .leading) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black)
                                    .padding(10)
                                
                                Spacer()
                                
                                Text("Upload Photo")
                                    .font(.callout)
                                    .foregroundColor(.black)
                                    .padding(10)
                            }
                            .frame(width: 160, height: 160, alignment: .leading)
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    wardrobeData.wardrobeItems[selectedCategory]?.append(image)
                }
            }
            .fullScreenCover(isPresented: $isCameraPresented) {
                ImagePicker(sourceType: .camera) { image in
                    wardrobeData.wardrobeItems[selectedCategory]?.append(image)
                }
            }
        }
    }
    
    // **Custom Image Picker**
    struct ImagePicker: UIViewControllerRepresentable {
        var sourceType: UIImagePickerController.SourceType
        var completion: (UIImage) -> Void
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.completion(image)
                }
                picker.dismiss(animated: true)
            }
        }
    }

