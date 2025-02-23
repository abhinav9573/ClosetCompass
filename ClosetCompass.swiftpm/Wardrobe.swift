import SwiftUI
import PhotosUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct WardrobeView: View {
    var wardrobeName: String
    @State private var selectedCategory: String = "Shirts"
    @State private var isSheetPresented = false
    @State private var isAddCategoryPopupPresented = false
    @State private var newCategoryName: String = ""
    @State private var selectedImageForPopup: UIImage? = nil
    @State private var selectedImages: [UIImage] = []
    @State private var imageToDelete: IdentifiableImage? = nil
    
    @EnvironmentObject private var wardrobeData: WardrobeData
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button(action: {
                                isAddCategoryPopupPresented.toggle()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(20)
                            }
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
                    Text(selectedCategory)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading)
                        .padding(.top, 5)
                    let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
                    
                    ScrollView {
                        LazyVGrid(columns: gridLayout, spacing: 15) {
                            ForEach(wardrobeData.wardrobeItems[selectedCategory] ?? [], id: \.self) { image in
                                WardrobeCard(image: image)
                                    .onTapGesture {
                                        selectedImageForPopup = image
                                    }
                                    .onLongPressGesture {
                                        imageToDelete = IdentifiableImage(image: image)
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                    }
                }
                .navigationTitle(wardrobeName)
                .navigationBarTitleDisplayMode(.large)
                .navigationBarBackButtonHidden(true)
                .overlay(
                    Button(action: {
                        isSheetPresented.toggle()
                    }) {
                        Text("Add to Wardrobe")
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
                .sheet(isPresented: $isSheetPresented) {
                    if #available(iOS 16.4, *) {
                        UploadClothesSheet(selectedCategory: selectedCategory, selectedImages: $selectedImages)
                            .environmentObject(wardrobeData)
                            .presentationDetents([.fraction(0.35)])
                            .presentationCornerRadius(20)
                    } else {
                    }
                }
                if isAddCategoryPopupPresented {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isAddCategoryPopupPresented = false
                        }
                    
                    VStack {
                        Text("Add New Category")
                            .font(.headline)
                            .padding()
                        
                        TextField("Enter category name", text: $newCategoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        HStack {
                            Button("Cancel") {
                                isAddCategoryPopupPresented = false
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            
                            Button("Save") {
                                if !newCategoryName.isEmpty {
                                    wardrobeData.addCategory(newCategoryName)
                                    newCategoryName = ""
                                    isAddCategoryPopupPresented = false
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
                    .transition(.scale)
                }
                if let selectedImageForPopup = selectedImageForPopup {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.selectedImageForPopup = nil
                            }
                        
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
                            
                            Button(action: {
                                self.selectedImageForPopup = nil
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
                        .frame(width: 300, height: 400)
                    }
                    .transition(.opacity)
                }
            }
            .alert(item: $imageToDelete) { identifiableImage in
                Alert(
                    title: Text("Remove Item"),
                    message: Text("Do you want to remove this clothing item?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let index = wardrobeData.wardrobeItems[selectedCategory]?.firstIndex(of: identifiableImage.image) {
                            wardrobeData.wardrobeItems[selectedCategory]?.remove(at: index)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct WardrobeCard: View {
    let image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .cornerRadius(10)
        }
        .frame(width: 180, height: 180)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(13)
    }
}

struct UploadClothesSheet: View {
    var selectedCategory: String
    @Binding var selectedImages: [UIImage]
    @EnvironmentObject private var wardrobeData: WardrobeData
    @State private var isImagePickerPresented = false
    @State private var isCameraPresented = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        VStack {
            Text("Upload new clothes")
                .font(.headline)
                .padding(.top)
            
            HStack(spacing: 20) {
                Button(action: {
                    checkCameraPermission()
                }) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.3))
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
                Button(action: { isImagePickerPresented.toggle() }) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 160, height: 160)
                        
                        VStack(alignment: .leading) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .padding(10)
                            
                            Spacer()
                            
                            Text("Upload Photos")
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
            ImagePicker(images: $selectedImages)
                .onDisappear {
                    if !selectedImages.isEmpty {
                        wardrobeData.wardrobeItems[selectedCategory]?.append(contentsOf: selectedImages)
                        selectedImages.removeAll()
                    }
                }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView { image in
                if let image = image {
                    wardrobeData.wardrobeItems[selectedCategory]?.append(image)
                }
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Camera Access Required"),
                message: Text("Please enable camera access in Settings to use this feature."),
                primaryButton: .default(Text("Open Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraPresented.toggle()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        isCameraPresented.toggle()
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.images.removeAll()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
            
            picker.dismiss(animated: true)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            } else {
                parent.completion(nil)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
        }
    }
}
