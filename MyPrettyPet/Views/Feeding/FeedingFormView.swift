//
//  FeedingFormView.swift
//  MyPrettyPet
//

import SwiftUI
import SwiftData

/// Новий запис годування (record == nil) або редагування існуючого
struct FeedingFormView: View {
    let pet: Pet
    let record: FeedingRecord?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage(AppSettings.ownerName) private var ownerName = ""

    @State private var foodName: String
    @State private var portion: String
    @State private var dateTime: Date
    @State private var notes: String
    @State private var showFoodTypes = false

    private let timeShortcuts: [(title: String, minutesAgo: Int)] = [
        ("Зараз", 0), ("15 хв тому", 15), ("30 хв тому", 30), ("1 год тому", 60), ("2 год тому", 120),
    ]

    init(pet: Pet, record: FeedingRecord? = nil) {
        self.pet = pet
        self.record = record
        _foodName = State(initialValue: record?.foodName ?? "")
        _portion = State(initialValue: record?.portion ?? "")
        _dateTime = State(initialValue: record?.dateTime ?? Date())
        _notes = State(initialValue: record?.notes ?? "")
    }

    var body: some View {
        FormScreen(
            title: record == nil ? "Годування" : "Редагування",
            saveTitle: record == nil ? "Погодувати" : "Зберегти",
            canSave: !foodName.trimmed.isEmpty,
            onSave: save
        ) {
            FormPetHeader(pet: pet, subtitle: record == nil ? "Що і скільки з'їв(ла)?" : "Редагування запису")

            FormSection(title: "Що їв(ла)") {
                if pet.activeFoodTypes.isEmpty {
                    Text("Немає збережених типів їжі")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.secondary)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                        ForEach(pet.activeFoodTypes) { food in
                            foodTile(food)
                        }
                    }
                }

                FormTextField(label: "Або своя назва", text: $foodName, placeholder: "Назва їжі", icon: "pencil")

                Button {
                    showFoodTypes = true
                } label: {
                    Label("Керувати типами їжі", systemImage: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
                .buttonStyle(.plain)
            }

            FormSection(title: "Порція") {
                FormTextField(label: "Скільки", text: $portion, placeholder: "50 г, 1 пакетик", icon: "scalemass.fill")
                if !recentPortions.isEmpty {
                    SuggestionChips(options: recentPortions, selected: portion.trimmed) { portion = $0 }
                }
            }

            FormSection(title: "Коли") {
                FormRow(label: "Час", icon: "clock.fill") {
                    DatePicker("", selection: $dateTime, in: ...Date())
                        .labelsHidden()
                }
                SuggestionChips(options: timeShortcuts.map(\.title)) { title in
                    if let shortcut = timeShortcuts.first(where: { $0.title == title }) {
                        dateTime = Date().addingTimeInterval(TimeInterval(-shortcut.minutesAgo * 60))
                    }
                }
            }

            FormSection(title: "Нотатки") {
                FormTextField(label: "Коментар", text: $notes, placeholder: "Необов'язково", icon: "text.alignleft", axis: .vertical)
            }
        }
        .sheet(isPresented: $showFoodTypes) {
            NavigationStack { FoodTypesView(pet: pet) }
        }
    }

    // MARK: - Food Tile

    private func foodTile(_ food: FoodType) -> some View {
        let isSelected = foodName == food.name

        return Button {
            select(food.name)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: food.category.icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(food.name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .foregroundColor(isSelected ? .white : Theme.Colors.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                isSelected ? Theme.Colors.accent : Theme.Colors.fieldBackground,
                in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    /// Останні різні порції для швидкого вибору
    private var recentPortions: [String] {
        var seen = Set<String>()
        return pet.sortedFeedings
            .map(\.portion)
            .filter { !$0.isEmpty && seen.insert($0).inserted }
            .prefix(5)
            .map { $0 }
    }

    /// Обрати їжу і підставити порцію з останнього такого годування
    private func select(_ name: String) {
        foodName = name
        if portion.trimmed.isEmpty, let last = pet.sortedFeedings.first(where: { $0.foodName == name }) {
            portion = last.portion
        }
    }

    private func save() {
        if let record {
            record.foodName = foodName.trimmed
            record.portion = portion.trimmed
            record.dateTime = dateTime
            record.notes = notes.nilIfBlank
        } else {
            let newRecord = FeedingRecord(
                foodName: foodName.trimmed,
                portion: portion.trimmed,
                dateTime: dateTime,
                notes: notes.nilIfBlank,
                fedByName: ownerName.nilIfBlank
            )
            context.insert(newRecord)
            newRecord.pet = pet
        }
        context.saveChanges()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    let container = Persistence.preview
    let pet = try! container.mainContext.fetch(FetchDescriptor<Pet>()).first!
    return FeedingFormView(pet: pet)
        .modelContainer(container)
}
