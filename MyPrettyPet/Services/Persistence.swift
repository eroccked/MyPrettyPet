//
//  Persistence.swift
//  MyPrettyPet
//

import Foundation
import SwiftData

enum Persistence {
    static let cloudKitContainerID = "iCloud.com.TarasBuhra.MyPrettyPet"

    static let schema = Schema([
        Pet.self,
        FeedingRecord.self,
        FoodType.self,
        MedicalRecord.self,
    ])

    /// Локальне сховище, яке автоматично синхронізується з приватною базою iCloud
    static func makeContainer() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(cloudKitContainerID)
        )

        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            print("❌ Не вдалося створити сховище з iCloud: \(error). Працюємо локально.")
            let localConfiguration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            do {
                return try ModelContainer(for: schema, configurations: localConfiguration)
            } catch {
                fatalError("Не вдалося створити сховище даних: \(error)")
            }
        }
    }

    /// Сховище в пам'яті з прикладом даних для Preview
    static let preview: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try! ModelContainer(for: schema, configurations: configuration)
        let context = container.mainContext

        let pet = Pet(name: "Мурчик", species: "Кіт")
        pet.breed = "Британець"
        pet.gender = .male
        pet.furColor = "Сірий"
        pet.dateOfBirth = Calendar.current.date(byAdding: .month, value: -26, to: Date()) ?? Date()
        pet.microchipNumber = "900123456789012"
        context.insert(pet)
        pet.addDefaultFoodTypes(in: context)

        let feeding = FeedingRecord(foodName: "Сухий корм", portion: "40 г", fedByName: "Тарас")
        context.insert(feeding)
        feeding.pet = pet

        let vaccination = MedicalRecord(kind: .vaccination, name: "Nobivac Tricat", dateAdministered: Date().addingTimeInterval(-350 * 86400))
        vaccination.nextDueDate = Date().addingTimeInterval(15 * 86400)
        context.insert(vaccination)
        vaccination.pet = pet

        return container
    }()
}

extension ModelContext {
    /// Зберегти зміни (щоб вони одразу пішли в iCloud) і оновити нагадування
    func saveChanges() {
        do {
            try save()
        } catch {
            print("❌ Помилка збереження: \(error)")
        }
        Task {
            await NotificationManager.shared.rescheduleAll(in: self)
        }
    }
}
