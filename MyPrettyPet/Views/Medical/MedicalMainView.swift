//
//  MedicalMainView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import SwiftData

struct MedicalMainView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @AppStorage(AppSettings.selectedPetID) private var selectedPetID = ""
    @State private var addingKind: MedicalRecord.Kind?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(title: "Медичне") {
                    if !pets.isEmpty {
                        AddMedicalRecordMenu(onDarkHeader: true) { addingKind = $0 }
                    }
                }

                if let pet = pets.selected(by: selectedPetID) {
                    if pets.count > 1 {
                        PetSelector(pets: pets, selectedPet: pet) { selectedPetID = $0.id.uuidString }
                    }
                    MedicalRecordsList(pet: pet)
                        .sheet(item: $addingKind) { kind in
                            MedicalRecordFormView(pet: pet, kind: kind)
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

/// Медичні записи конкретної тварини — відкривається з картки тварини
struct MedicalRecordsScreen: View {
    let pet: Pet
    @State private var addingKind: MedicalRecord.Kind?

    var body: some View {
        MedicalRecordsList(pet: pet)
            .background(Theme.Colors.background)
            .navigationTitle("Медичні записи")
            .navigationBarTitleDisplayMode(.inline)
            .headerNavigationBar()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AddMedicalRecordMenu { addingKind = $0 }
                }
            }
            .sheet(item: $addingKind) { kind in
                MedicalRecordFormView(pet: pet, kind: kind)
            }
    }
}

// MARK: - Add Menu
struct AddMedicalRecordMenu: View {
    var onDarkHeader = false
    let onSelect: (MedicalRecord.Kind) -> Void

    var body: some View {
        Menu {
            ForEach(MedicalRecord.Kind.allCases) { kind in
                Button {
                    onSelect(kind)
                } label: {
                    Label(kind.title, systemImage: kind.icon)
                }
            }
        } label: {
            if onDarkHeader {
                HeaderIconLabel(systemImage: "plus")
            } else {
                Image(systemName: "plus")
            }
        }
        .accessibilityLabel("Додати медичний запис")
    }
}

// MARK: - Records List
struct MedicalRecordsList: View {
    let pet: Pet

    @Environment(\.modelContext) private var context
    @State private var filter: MedicalRecord.Kind?
    @State private var editingRecord: MedicalRecord?

    var body: some View {
        let upcoming = pet.upcomingReminders.filter { filter == nil || $0.kind == filter }
        let history = pet.sortedMedicalRecords.filter { filter == nil || $0.kind == filter }

        List {
            Section {
                Picker("Тип", selection: $filter) {
                    Text("Усі").tag(MedicalRecord.Kind?.none)
                    ForEach(MedicalRecord.Kind.allCases) { kind in
                        Text(kind.shortTitle).tag(Optional(kind))
                    }
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            if !upcoming.isEmpty {
                Section("Найближчі") {
                    ForEach(upcoming) { record in
                        recordButton(record, showsDueDate: true)
                    }
                }
            }

            Section("Історія") {
                if history.isEmpty {
                    Text("Записів поки немає. Натисніть «+», щоб додати.")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.secondary)
                }
                ForEach(history) { record in
                    recordButton(record, showsDueDate: false)
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
        .scrollContentBackground(.hidden)
        .sheet(item: $editingRecord) { record in
            MedicalRecordFormView(pet: pet, kind: record.kind, record: record)
        }
    }

    private func recordButton(_ record: MedicalRecord, showsDueDate: Bool) -> some View {
        Button {
            editingRecord = record
        } label: {
            MedicalRecordRow(record: record, showsDueDate: showsDueDate)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Record Row
struct MedicalRecordRow: View {
    let record: MedicalRecord
    /// true — показувати, коли наступна процедура; false — коли була зроблена
    var showsDueDate: Bool = false

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: record.kind.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(record.kind.color)
                .frame(width: 44, height: 44)
                .background(record.kind.softColor, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(record.name)
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.primary)

                Text(subtitle)
                    .font(Theme.Fonts.footnote)
                    .foregroundColor(Theme.Colors.secondary)
            }

            Spacer(minLength: 0)

            if showsDueDate, let dueText = record.dueText {
                Text(dueText)
                    .font(Theme.Fonts.caption.weight(.semibold))
                    .foregroundColor(record.dueColor)
                    .multilineTextAlignment(.trailing)
            }
        }
        .contentShape(Rectangle())
    }

    private var subtitle: String {
        if showsDueDate, let nextDueDate = record.nextDueDate {
            return "\(record.kind.title) • \(nextDueDate.toMediumString())"
        }
        var parts = [record.kind.title, record.dateAdministered.toMediumString()]
        if let nextDueDate = record.nextDueDate {
            parts.append("наступне \(nextDueDate.toShortString())")
        }
        return parts.joined(separator: " • ")
    }
}

// MARK: - Preview
#Preview {
    MedicalMainView()
        .modelContainer(Persistence.preview)
}
