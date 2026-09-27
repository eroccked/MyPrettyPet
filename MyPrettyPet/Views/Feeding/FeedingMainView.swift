//
//  FeedingMainView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import SwiftData

struct FeedingMainView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @AppStorage(AppSettings.selectedPetID) private var selectedPetID = ""
    @State private var showAddFeeding = false
    @State private var showFoodTypes = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(title: "Годування") {
                    if !pets.isEmpty {
                        HeaderIconButton(systemImage: "list.bullet", accessibilityTitle: "Типи їжі") {
                            showFoodTypes = true
                        }
                        HeaderIconButton(systemImage: "plus", accessibilityTitle: "Погодувати") {
                            showAddFeeding = true
                        }
                    }
                }

                if let pet = pets.selected(by: selectedPetID) {
                    if pets.count > 1 {
                        PetSelector(pets: pets, selectedPet: pet) { selectedPetID = $0.id.uuidString }
                    }
                    FeedingHistoryList(pet: pet)
                        .sheet(isPresented: $showAddFeeding) {
                            FeedingFormView(pet: pet)
                        }
                        .sheet(isPresented: $showFoodTypes) {
                            NavigationStack { FoodTypesView(pet: pet) }
                        }
                } else {
                    NoPetsView()
                }
            }
            .background(Theme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

/// Історія годування, що відкривається з картки тварини
struct FeedingHistoryScreen: View {
    let pet: Pet
    @State private var showAddFeeding = false

    var body: some View {
        FeedingHistoryList(pet: pet)
            .background(Theme.Colors.background)
            .navigationTitle("Історія годування")
            .navigationBarTitleDisplayMode(.inline)
            .headerNavigationBar()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddFeeding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Погодувати")
                }
            }
            .sheet(isPresented: $showAddFeeding) {
                FeedingFormView(pet: pet)
            }
    }
}

// MARK: - Feeding History List
struct FeedingHistoryList: View {
    let pet: Pet

    @Environment(\.modelContext) private var context
    @State private var editingRecord: FeedingRecord?

    var body: some View {
        List {
            Section {
                HStack {
                    summaryItem(value: "\(pet.todayFeedingCount)", label: "сьогодні", icon: "fork.knife")
                    Divider()
                    summaryItem(value: pet.lastFeeding?.dateTime.timeAgo() ?? "—", label: "востаннє", icon: "clock")
                }
                .padding(.vertical, 4)
            }

            if pet.feedingsByDay.isEmpty {
                Section {
                    Text("Записів ще немає. Натисніть «+», щоб додати перше годування.")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.secondary)
                }
            }

            ForEach(pet.feedingsByDay) { group in
                Section(dayTitle(group.day)) {
                    ForEach(group.records) { record in
                        Button {
                            editingRecord = record
                        } label: {
                            FeedingRow(record: record)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                context.delete(record)
                                context.saveChanges()
                            } label: {
                                Label("Видалити", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .sheet(item: $editingRecord) { record in
            FeedingFormView(pet: pet, record: record)
        }
    }

    private func summaryItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 36, height: 36)
                .background(Theme.Colors.pinkSoft, in: Circle())
            Text(value)
                .font(Theme.Fonts.title2)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundColor(Theme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayTitle(_ day: Date) -> String {
        if Calendar.current.isDateInToday(day) { return "Сьогодні" }
        if Calendar.current.isDateInYesterday(day) { return "Вчора" }
        return day.toLongString()
    }
}

// MARK: - Feeding Row
struct FeedingRow: View {
    let record: FeedingRecord

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            Text(record.dateTime.toString(format: "HH:mm"))
                .font(Theme.Fonts.headline)
                .monospacedDigit()
                .foregroundColor(Theme.Colors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.foodName)
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.primary)

                let details = [record.portion.nilIfBlank, record.fedByName.map { "годував(ла): \($0)" }].compactMap { $0 }
                if !details.isEmpty {
                    Text(details.joined(separator: " • "))
                        .font(Theme.Fonts.footnote)
                        .foregroundColor(Theme.Colors.secondary)
                }

                if let notes = record.notes {
                    Text(notes)
                        .font(Theme.Fonts.footnote)
                        .foregroundColor(Theme.Colors.secondary)
                        .italic()
                }
            }

            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    FeedingMainView()
        .modelContainer(Persistence.preview)
}
