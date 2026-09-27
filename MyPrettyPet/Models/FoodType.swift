//
//  FoodType.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftData

@Model
final class FoodType {
    var id: UUID = UUID()
    var name: String = ""
    var categoryRaw: String = "other"
    var isActive: Bool = true
    var createdAt: Date = Date()

    var pet: Pet?

    init(name: String, category: Category) {
        self.name = name
        self.categoryRaw = category.rawValue
    }
}

extension FoodType {
    enum Category: String, CaseIterable, Identifiable {
        case dryFood, wetFood, treats, natural, supplements, other

        var id: Self { self }

        var title: String {
            switch self {
            case .dryFood: "Сухий корм"
            case .wetFood: "Вологий корм"
            case .treats: "Ласощі"
            case .natural: "Натуральна їжа"
            case .supplements: "Добавки"
            case .other: "Інше"
            }
        }

        var icon: String {
            switch self {
            case .dryFood: "circle.grid.3x3.fill"
            case .wetFood: "drop.fill"
            case .treats: "star.fill"
            case .natural: "leaf.fill"
            case .supplements: "pills.fill"
            case .other: "fork.knife"
            }
        }
    }

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
