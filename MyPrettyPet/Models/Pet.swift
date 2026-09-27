//
//  Pet.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftData

// Для синхронізації з CloudKit усі поля мають бути опціональні або мати значення за замовчуванням,
// а зв'язки — опціональні.
@Model
final class Pet {
    var id: UUID = UUID()
    var name: String = ""
    var species: String = ""
    var breed: String = ""
    var genderRaw: String = "unknown"
    var dateOfBirth: Date = Date()
    @Attribute(.externalStorage) var photoData: Data?
    var furColor: String = ""

    var microchipNumber: String?
    var microchipDate: Date?
    var microchipLocation: String?
    var tattooNumber: String?
    var tattooDate: Date?

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \FeedingRecord.pet)
    var feedingRecords: [FeedingRecord]? = []

    @Relationship(deleteRule: .cascade, inverse: \FoodType.pet)
    var foodTypes: [FoodType]? = []

    @Relationship(deleteRule: .cascade, inverse: \MedicalRecord.pet)
    var medicalRecords: [MedicalRecord]? = []

    init(name: String, species: String) {
        self.name = name
        self.species = species
    }
}

// MARK: - Gender
extension Pet {
    enum Gender: String, CaseIterable, Identifiable {
        case male, female, unknown

        var id: Self { self }

        var title: String {
            switch self {
            case .male: "Самець"
            case .female: "Самка"
            case .unknown: "Невідомо"
            }
        }
    }

    var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .unknown }
        set { genderRaw = newValue.rawValue }
    }
}

// MARK: - Computed
extension Pet {
    var ageText: String {
        let age = Calendar.current.dateComponents([.year, .month], from: dateOfBirth, to: Date())
        let years = age.year ?? 0
        let months = age.month ?? 0

        if years > 0 {
            return months > 0 ? "\(years) р. \(months) міс." : "\(years) р."
        } else if months > 0 {
            return "\(months) міс."
        }
        return "Новонароджений"
    }

    // MARK: Feeding

    var sortedFeedings: [FeedingRecord] {
        (feedingRecords ?? []).sorted { $0.dateTime > $1.dateTime }
    }

    var lastFeeding: FeedingRecord? {
        sortedFeedings.first
    }

    var todayFeedingCount: Int {
        (feedingRecords ?? []).filter { Calendar.current.isDateInToday($0.dateTime) }.count
    }

    var feedingsByDay: [FeedingDayGroup] {
        let grouped = Dictionary(grouping: sortedFeedings) { Calendar.current.startOfDay(for: $0.dateTime) }
        return grouped
            .map { FeedingDayGroup(day: $0.key, records: $0.value) }
            .sorted { $0.day > $1.day }
    }

    var activeFoodTypes: [FoodType] {
        (foodTypes ?? []).filter(\.isActive).sorted { $0.name < $1.name }
    }

    var archivedFoodTypes: [FoodType] {
        (foodTypes ?? []).filter { !$0.isActive }.sorted { $0.name < $1.name }
    }

    // MARK: Medical

    var sortedMedicalRecords: [MedicalRecord] {
        (medicalRecords ?? []).sorted { $0.dateAdministered > $1.dateAdministered }
    }

    /// Останні записи кожної процедури (тип + назва), у яких вказана наступна дата.
    /// Старіші записи тієї ж процедури вважаються виконаними і не нагадують.
    var currentReminders: [MedicalRecord] {
        var latest: [String: MedicalRecord] = [:]
        for record in medicalRecords ?? [] {
            let key = "\(record.kindRaw)|\(record.name.trimmingCharacters(in: .whitespaces).lowercased())"
            if let existing = latest[key], existing.dateAdministered >= record.dateAdministered {
                continue
            }
            latest[key] = record
        }
        return latest.values
            .compactMap { record in record.nextDueDate.map { (record, $0) } }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
    }

    /// Прострочені або ті, що будуть протягом 30 днів
    var upcomingReminders: [MedicalRecord] {
        currentReminders.filter { ($0.daysUntilDue ?? .max) <= 30 }
    }

    var hasOverdueReminders: Bool {
        currentReminders.contains { ($0.daysUntilDue ?? 0) < 0 }
    }
}

// MARK: - Default Food Types
extension Pet {
    func addDefaultFoodTypes(in context: ModelContext) {
        let defaults: [(String, FoodType.Category)] = [
            ("Сухий корм", .dryFood),
            ("Вологий корм", .wetFood),
            ("Курка", .natural),
            ("Яловичина", .natural),
            ("Риба", .natural),
            ("Ласощі", .treats),
        ]

        for (name, category) in defaults {
            let food = FoodType(name: name, category: category)
            context.insert(food)
            food.pet = self
        }
    }
}

struct FeedingDayGroup: Identifiable {
    let day: Date
    let records: [FeedingRecord]

    var id: Date { day }
}

extension Array where Element == Pet {
    /// Обрана тварина за збереженим ID або перша у списку
    func selected(by id: String) -> Pet? {
        first { $0.id.uuidString == id } ?? first
    }
}
