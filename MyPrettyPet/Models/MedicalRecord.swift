//
//  MedicalRecord.swift
//  MyPrettyPet
//

import Foundation
import SwiftData
import SwiftUI

/// Щеплення, глистування або обробка від бліх
@Model
final class MedicalRecord {
    var id: UUID = UUID()
    var kindRaw: String = "vaccination"
    var name: String = ""
    var dateAdministered: Date = Date()
    var nextDueDate: Date?

    var clinic: String?
    var serialNumber: String?
    var dosage: String?
    var treatmentTypeRaw: String?
    var notes: String?

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var pet: Pet?

    init(kind: Kind, name: String, dateAdministered: Date) {
        self.kindRaw = kind.rawValue
        self.name = name
        self.dateAdministered = dateAdministered
    }
}

// MARK: - Kind
extension MedicalRecord {
    enum Kind: String, CaseIterable, Identifiable {
        case vaccination, deworming, fleaTreatment

        var id: Self { self }

        var title: String {
            switch self {
            case .vaccination: "Щеплення"
            case .deworming: "Глистування"
            case .fleaTreatment: "Обробка від бліх"
            }
        }

        var shortTitle: String {
            switch self {
            case .vaccination: "Щеплення"
            case .deworming: "Глисти"
            case .fleaTreatment: "Блохи"
            }
        }

        var namePlaceholder: String {
            switch self {
            case .vaccination: "Назва вакцини"
            case .deworming: "Назва препарату"
            case .fleaTreatment: "Назва засобу"
            }
        }

        var icon: String {
            switch self {
            case .vaccination: "syringe.fill"
            case .deworming: "pills.fill"
            case .fleaTreatment: "ant.fill"
            }
        }

        var color: Color {
            switch self {
            case .vaccination: Theme.Colors.blue
            case .deworming: Theme.Colors.orange
            case .fleaTreatment: Theme.Colors.green
            }
        }

        var softColor: Color {
            switch self {
            case .vaccination: Theme.Colors.lavenderSoft
            case .deworming: Theme.Colors.peachSoft
            case .fleaTreatment: Theme.Colors.mintSoft
            }
        }

        /// Типові інтервали повторення, у місяцях
        var intervalOptions: [Int] {
            switch self {
            case .vaccination: [6, 12]
            case .deworming: [1, 3, 6]
            case .fleaTreatment: [1, 2, 3]
            }
        }

        var defaultIntervalMonths: Int {
            switch self {
            case .vaccination: 12
            case .deworming: 3
            case .fleaTreatment: 1
            }
        }
    }

    enum TreatmentType: String, CaseIterable, Identifiable {
        case drops, collar, tablets, spray, other

        var id: Self { self }

        var title: String {
            switch self {
            case .drops: "Краплі"
            case .collar: "Нашийник"
            case .tablets: "Таблетки"
            case .spray: "Спрей"
            case .other: "Інше"
            }
        }
    }

    var kind: Kind {
        get { Kind(rawValue: kindRaw) ?? .vaccination }
        set { kindRaw = newValue.rawValue }
    }

    var treatmentType: TreatmentType? {
        get { treatmentTypeRaw.flatMap(TreatmentType.init(rawValue:)) }
        set { treatmentTypeRaw = newValue?.rawValue }
    }
}

// MARK: - Due Date
extension MedicalRecord {
    /// Кількість днів до наступної процедури (від'ємне — прострочено)
    var daysUntilDue: Int? {
        guard let nextDueDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: nextDueDate)
        ).day
    }

    var dueText: String? {
        guard let days = daysUntilDue, let nextDueDate else { return nil }
        switch days {
        case ..<0: return "Прострочено на \(-days) дн."
        case 0: return "Сьогодні"
        case 1: return "Завтра"
        case 2...30: return "Через \(days) дн."
        default: return nextDueDate.toMediumString()
        }
    }

    var dueColor: Color {
        guard let days = daysUntilDue else { return .secondary }
        switch days {
        case ..<0: return .red
        case 0...7: return Theme.Colors.orange
        default: return Theme.Colors.secondary
        }
    }
}
