import SwiftUI
import PhotosUI

struct PlanAndPackView: View {
    @State private var isShowingPlanForm = false
    @State private var trips: [Trip] = []
    @EnvironmentObject private var wardrobeData: WardrobeData
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: { isShowingPlanForm.toggle() }) {
                    HStack {
                        Text("Pack for a Trip")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black))
                    .padding()
                }
                
                ScrollView {
                    ForEach(trips) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(trip.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "suitcase.rolling.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                        .opacity(0.8)
                                }
                                
                                Text("\(trip.date.formatted(date: .abbreviated, time: .omitted)) - \(trip.days) day\(trip.days > 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(trip.packedItems.values.flatMap { $0 }.count) items packed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive, action: {
                                if let index = trips.firstIndex(where: { $0.id == trip.id }) {
                                    trips.remove(at: index)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Plan & Pack")
            .sheet(isPresented: $isShowingPlanForm) {
                PlanTripForm(trips: $trips)
                    .environmentObject(wardrobeData)
            }
        }
    }
}

struct PlanTripForm: View {
    @Binding var trips: [Trip]
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var wardrobeData: WardrobeData
    @State private var tripName: String = ""
    @State private var tripDate: Date = Date()
    @State private var numberOfDays: Int = 1
    @State private var selectedItems: [String: [UIImage]] = [:]
    
    var isSaveButtonDisabled: Bool {
        tripName.isEmpty || selectedItems.values.flatMap { $0 }.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Trip Name", text: $tripName)
                    DatePicker("Date", selection: $tripDate, displayedComponents: .date)
                    Stepper("No. Of Days: \(numberOfDays)", value: $numberOfDays, in: 1...30)
                }
                
                Section(header: Text("Pack Your Clothes")) {
                    ForEach(wardrobeData.categories, id: \.self) { category in
                        NavigationLink(destination: CategorySelectionView(category: category, selectedItems: $selectedItems)) {
                            HStack {
                                Text(category)
                                Spacer()
                                Text("\(selectedItems[category]?.count ?? 0)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let newTrip = Trip(name: tripName, date: tripDate, days: numberOfDays, packedItems: selectedItems)
                    trips.append(newTrip)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(isSaveButtonDisabled)
            )
            .navigationTitle("New Trip")
        }
    }
}
struct CategorySelectionView: View {
    let category: String
    @Binding var selectedItems: [String: [UIImage]]
    
    @EnvironmentObject private var wardrobeData: WardrobeData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(wardrobeData.wardrobeItems[category] ?? [], id: \.self) { image in
                    ZStack(alignment: .topTrailing) {
                        WardrobeCard(image: image)
                        
                        if selectedItems[category]?.contains(image) == true {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .transition(.scale)
                        }
                    }
                    .onTapGesture {
                        toggleSelection(for: image)
                    }
                    .onLongPressGesture {
                        toggleSelection(for: image)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
    }
    
    private func toggleSelection(for image: UIImage) {
        if let index = selectedItems[category]?.firstIndex(of: image) {
            selectedItems[category]?.remove(at: index)
        } else {
            selectedItems[category, default: []].append(image)
        }
    }
}
struct TripDetailView: View {
    let trip: Trip
    @State private var expandedCategories: Set<String> = []
    @State private var selectedCategory: String? = nil
    
    var body: some View {
        Form {
            ForEach(trip.packedItems.keys.sorted(), id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    HStack {
                        Text(category)
                        Spacer()
                        Text("\(trip.packedItems[category]?.count ?? 0)")
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle(trip.name)
        .sheet(item: $selectedCategory) { category in
            CategoryImagesModalView(category: category, images: trip.packedItems[category] ?? [])
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct CategoryImagesModalView: View {
    let category: String
    let images: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(images, id: \.self) { image in
                        WardrobeCard(image: image)
                    }
                }
                .padding()
            }
            .navigationTitle(category)
            .navigationBarItems(
                trailing: Button("Done") {
                    
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
