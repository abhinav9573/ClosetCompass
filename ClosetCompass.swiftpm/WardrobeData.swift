import SwiftUI

class WardrobeData: ObservableObject {
    @Published var wardrobeItems: [String: [UIImage]] = [:]
    @Published var categoriesOrder: [String] = ["Shirts", "T-Shirts", "Jackets", "Jeans", "Trousers", "Shoes"]
    @Published var gender: String = "Male" {
        didSet {
            updateWardrobeItemsForGender()
        }
    }
    
    init() {
        updateWardrobeItemsForGender()
    }

    var categories: [String] {
        switch gender {
        case "Female":
            return ["Shirts", "Kurti", "Jeans", "T-Shirt", "Top", "Leggings", "Shoes", "Heels", "Sandals",]
        default:
            return categoriesOrder
        }
    }

    private func updateWardrobeItemsForGender() {
        switch gender {
        case "Female":
            wardrobeItems = [
                "Top": [UIImage(named: "top1"),UIImage(named: "top2"),UIImage(named: "top3"),UIImage(named: "top5")].compactMap { $0 },
                "Kurti": [UIImage(named: "kurti1"),UIImage(named: "kurti2"),UIImage(named: "kurti3")].compactMap { $0 },
                "Jeans": [UIImage(named: "jeans1"),UIImage(named: "jeans2"),UIImage(named: "jeans3"),UIImage(named: "jeans4")].compactMap { $0 },
                "T-Shirt": [UIImage(named: "tshirt"),UIImage(named: "tshirt2"),UIImage(named: "tshirt3"),UIImage(named: "tshirt4")].compactMap { $0 },
                "Shirts": [UIImage(named: "LadiesShirt1"),UIImage(named: "LadiesShirt2"),UIImage(named: "LadiesShirt3"),UIImage(named: "LadiesShirt4")].compactMap { $0 },
                "Leggings": [UIImage(named: "leggings1"),UIImage(named: "leggings2"),UIImage(named: "leggings3")].compactMap { $0 },
                "Shoes": [UIImage(named: "shoes"),UIImage(named: "shoes1"),UIImage(named: "shoes2"),UIImage(named: "shoes3")].compactMap { $0 },
                "Heels": [UIImage(named: "heel1"),UIImage(named: "heel2"),UIImage(named: "heel3"),UIImage(named: "heel4"),UIImage(named: "heel5")].compactMap { $0 },
                "Sandals": [UIImage(named: "sandle1"),UIImage(named: "sandle2"),UIImage(named: "sandle3")].compactMap { $0 },
            ]
        default: // Male
            wardrobeItems = [
                "Shirts": [UIImage(named: "shirt"),UIImage(named: "shirt1"),UIImage(named: "shirt2"),UIImage(named: "shirt3")].compactMap { $0 },
                "T-Shirts": [UIImage(named: "tshirt"),UIImage(named: "tshirt2"),UIImage(named: "tshirt3"),UIImage(named: "tshirt4")].compactMap { $0 },
                "Jackets": [UIImage(named: "jacket1"),UIImage(named: "jacket2"),UIImage(named: "jacket3"),UIImage(named: "jacket4"),UIImage(named: "jacket5")].compactMap { $0 },
                "Jeans": [UIImage(named: "jeans1"),UIImage(named: "jeans2"),UIImage(named: "jeans3"),UIImage(named: "jeans4")].compactMap { $0 },
                "Trousers": [UIImage(named: "trouser"),UIImage(named: "trouser1"),UIImage(named: "trouser2"),UIImage(named: "trouser3"),UIImage(named: "trouser4")].compactMap { $0 },
                "Shoes": [UIImage(named: "shoes"),UIImage(named: "shoes1"),UIImage(named: "shoes2"),UIImage(named: "shoes3")].compactMap { $0 }
            ]
        }
    }
    func addCategory(_ category: String) {
        wardrobeItems[category] = []
        categoriesOrder.insert(category, at: 0)
    }
}

struct Trip: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let days: Int
    var packedItems: [String: [UIImage]]
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let isQuestion: Bool
}
