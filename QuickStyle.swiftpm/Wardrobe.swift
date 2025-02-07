import SwiftUI
import PhotosUI

struct WardrobeView: View {
    @State private var selectedCategory: String = "Shirts"
    @State private var isSheetPresented = false
    @State private var selectedImage: UIImage?
    
    let categories = ["Shirts", "T-Shirts", "Jackets", "Jeans", "Trousers", "Shoes"]
    
    @State private var wardrobeItems: [String: [UIImage]] = [
        "Shirts": [],
        "T-Shirts": [],
        "Jackets": [],
        "Jeans": [],
        "Trousers": [],
        "Shoes": []
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                // **Category Buttons**
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
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
                    LazyVGrid(columns: gridLayout, spacing: 1) {
                        ForEach(wardrobeItems[selectedCategory] ?? [], id: \.self) { image in
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 160, height: 160) // Fixed Frame Size
                                    .clipped()
                                    .cornerRadius(10) // Adds spacing inside the card
                            }
                            .frame(width: 180, height: 180) // Card size
                            .background(Color.white) // Card background
                            .cornerRadius(13)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }

            }
            .navigationTitle("My Wardrobe")
            .navigationBarTitleDisplayMode(.large)
            
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
                    UploadClothesSheet(selectedCategory: selectedCategory, wardrobeItems: $wardrobeItems)
                        .presentationDetents([.fraction(0.35)]) // Show modal at ~35% height
                        .presentationCornerRadius(20)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}

// **Bottom Sheet View**
struct UploadClothesSheet: View {
    var selectedCategory: String
    @Binding var wardrobeItems: [String: [UIImage]]
    
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
                wardrobeItems[selectedCategory]?.append(image)
            }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera) { image in
                wardrobeItems[selectedCategory]?.append(image)
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

// **Preview**
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        WardrobeView()
    }
}
