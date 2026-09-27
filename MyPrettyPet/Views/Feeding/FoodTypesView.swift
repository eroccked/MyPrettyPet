//
//  FoodTypesView.swift
//  MyPrettyPet
//

import SwiftUI
import SwiftData

/// Список їжі тварини: додавання, архівування, видалення
struct FoodTypesView: View {
    let pet: Pet

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var newName = ""
    @State private var newCategory: FoodType.Category = .dryFood

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                FormSection(title: "Новий тип") {
                    FormTextField(label: "Назва", text: $newName, placeholder: "Напр. Royal Canin", icon: "fork.knife")
                    ChipPicker(
                        options: FoodType.Category.allCases,
                        selection: $newCategory,
                        title: { $0.title },
                        icon: { $0.icon }
                    )
                    Button {
                        addFood()
                    } label: {
                        Label("Додати", systemImage: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Theme.Colors.accent, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!canAdd)
                    .opacity(canAdd ? 1 : 0.45)
                }

                FormSection(title: "Активні") {
                    if pet.activeFoodTypes.isEmpty {
                        Text("Немає активних типів їжі")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(Theme.Colors.secondary)
                    }
                    ForEach(pet.activeFoodTypes) { food in
                        foodRow(food, isArchived: false)
                    }
                }

                if !pet.archivedFoodTypes.isEmpty {
                    FormSection(title: "Архів") {
                        ForEach(pet.archivedFoodTypes) { food in
                            foodRow(food, isArchived: true)
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.vertical, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.Colors.background)
        .navigationTitle("Типи їжі")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") { dismiss() }
            }
        }
        .tint(Theme.Colors.accent)
    }

    private var canAdd: Bool {
        !newName.trimmed.isEmpty && !isDuplicate
    }

    private var isDuplicate: Bool {
        (pet.foodTypes ?? []).contains { $0.name.lowercased() == newName.trimmed.lowercased() }
    }

    private func foodRow(_ food: FoodType, isArchived: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: food.category.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isArchived ? Theme.Colors.secondary : Theme.Colors.accent)
                .frame(width: 40, height: 40)
                .background(isArchived ? Theme.Colors.fieldBackground : Theme.Colors.pinkSoft, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isArchived ? Theme.Colors.secondary : Theme.Colors.primary)
                Text(food.category.title)
                    .font(Theme.Fonts.footnote)
                    .foregroundColor(Theme.Colors.secondary)
            }

            Spacer()

            Menu {
                if isArchived {
                    Button {
                        setActive(food, true)
                    } label: {
                        Label("Повернути", systemImage: "arrow.uturn.backward")
                    }
                } else {
                    Button {
                        setActive(food, false)
                    } label: {
                        Label("В архів", systemImage: "archivebox")
                    }
                }
                Button(role: .destructive) {
                    delete(food)
                } label: {
                    Label("Видалити", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.Colors.secondary)
                    .frame(width: 36, height: 36)
                    .background(Theme.Colors.fieldBackground, in: Circle())
            }
        }
    }

    private func addFood() {
        let food = FoodType(name: newName.trimmed, category: newCategory)
        context.insert(food)
        food.pet = pet
        context.saveChanges()
        newName = ""
    }

    private func setActive(_ food: FoodType, _ isActive: Bool) {
        withAnimation { food.isActive = isActive }
        context.saveChanges()
    }

    private func delete(_ food: FoodType) {
        withAnimation { context.delete(food) }
        context.saveChanges()
    }
}
