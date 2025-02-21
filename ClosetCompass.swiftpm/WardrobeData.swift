import SwiftUI

class WardrobeData: ObservableObject {
    @Published var wardrobeItems: [String: [UIImage]] = [:]
    @Published var categoriesOrder: [String] = ["Shirts", "T-Shirts", "Jackets", "Jeans", "Trousers", "Shoes"]
    @Published var gender: String = "Male" { // Default to Male
        didSet {
            // Update wardrobeItems when gender changes
            updateWardrobeItemsForGender()
        }
    }
    
    init() {
        updateWardrobeItemsForGender() // Initialize wardrobeItems based on default gender
    }
    
    // Computed property to get categories based on gender
    var categories: [String] {
        switch gender {
        case "Female":
            return ["Shirts", "Kurti", "Jeans", "T-Shirt", "Top", "Leggings", "Shoes", "Heels", "Sandals", "Other"]
        default: // Male
            return categoriesOrder
        }
    }
    
    // Update wardrobeItems based on gender
    private func updateWardrobeItemsForGender() {
        switch gender {
        case "Female":
            wardrobeItems = [
                "Top": [],
                "Kurti": [],
                "Jeans": [],
                "T-Shirt": [],
                "Shirt": [],
                "Leggings": [],
                "Shoes": [],
                "Heels": [],
                "Sandals": [],
                "Other": []
            ]
        default: // Male
            wardrobeItems = [
                "Shirts": [UIImage(named: "male")].compactMap { $0 },
                "T-Shirts": [],
                "Jackets": [],
                "Jeans": [],
                "Trousers": [],
                "Shoes": []
            ]
        }
    }
    
    func addCategory(_ category: String) {
        wardrobeItems[category] = [] // Add a new category with an empty image array
        categoriesOrder.insert(category, at: 0) // Insert the new category at the beginning
    }
}
struct Trip: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let days: Int
    var packedItems: [String: [UIImage]]
}
