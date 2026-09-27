//
//  MedicalRecordFormView.swift
//  MyPrettyPet
//

import SwiftUI
import SwiftData

/// Новий медичний запис (record == nil) або редагування існуючого
struct MedicalRecordFormView: View {
    let pet: Pet
    let record: MedicalRecord?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @AppStorage(AppSettings.reminderDaysBefore) private var reminderDaysBefore = AppSettings.defaultReminderDaysBefore

    @State private var kind: MedicalRecord.Kind
    @State private var name: String
    @State private var dateAdministered: Date
    @State private var hasNextDue: Bool
    @State private var nextDueDate: Date
    @State private var clinic: String
    @State private var serialNumber: String
    @State private var dosage: String
    @State private var treatmentType: MedicalRecord.TreatmentType
    @State private var notes: String

    init(pet: Pet, kind: MedicalRecord.Kind, record: MedicalRecord? = nil) {
        self.pet = pet
        self.record = record
        let date = record?.dateAdministered ?? Date()
        _kind = State(initialValue: record?.kind ?? kind)
        _name = State(initialValue: record?.name ?? "")
        _dateAdministered = State(initialValue: date)
        _hasNextDue = State(initialValue: record == nil || record?.nextDueDate != nil)
        _nextDueDate = State(initialValue: record?.nextDueDate
            ?? Calendar.current.date(byAdding: .month, value: kind.defaultIntervalMonths, to: date)
            ?? date)
        _clinic = State(initialValue: record?.clinic ?? "")
        _serialNumber = State(initialValue: record?.serialNumber ?? "")
        _dosage = State(initialValue: record?.dosage ?? "")
        _treatmentType = State(initialValue: record?.treatmentType ?? .drops)
        _notes = State(initialValue: record?.notes ?? "")
    }

    var body: some View {
        FormScreen(
            title: record == nil ? kind.title : "Редагування",
            saveTitle: "Зберегти",
            canSave: !name.trimmed.isEmpty,
            onSave: save
        ) {
            if record == nil {
                HStack(spacing: 10) {
                    ForEach(MedicalRecord.Kind.allCases) { option in
                        kindTile(option)
                    }
                }
            } else {
                FormPetHeader(pet: pet, subtitle: kind.title)
            }

            FormSection(title: "Процедура") {
                FormTextField(label: "Назва", text: $name, placeholder: kind.namePlaceholder, icon: kind.icon)
                FormRow(label: "Дата", icon: "calendar") {
                    DatePicker("", selection: $dateAdministered, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                }
            }

            FormSection(title: "Наступна процедура", footer: reminderFooter) {
                FormToggle(label: "Нагадати про наступну", icon: "bell.fill", isOn: $hasNextDue)

                if hasNextDue {
                    FormRow(label: "Дата", icon: "calendar.badge.clock") {
                        DatePicker("", selection: $nextDueDate, in: dateAdministered..., displayedComponents: .date)
                            .labelsHidden()
                    }
                    SuggestionChips(
                        options: kind.intervalOptions.map(intervalTitle),
                        selected: selectedIntervalTitle
                    ) { title in
                        if let months = kind.intervalOptions.first(where: { intervalTitle($0) == title }) {
                            setNextDue(months: months)
                        }
                    }
                }
            }

            detailsSection

            FormSection(title: "Нотатки") {
                FormTextField(label: "Коментар", text: $notes, placeholder: "Необов'язково", icon: "text.alignleft", axis: .vertical)
            }
        }
        .onChange(of: kind) { _, newKind in
            if record == nil {
                setNextDue(months: newKind.defaultIntervalMonths)
            }
        }
        .onChange(of: dateAdministered) { _, newDate in
            if nextDueDate < newDate {
                setNextDue(months: kind.defaultIntervalMonths)
            }
        }
    }

    // MARK: - Kind Tile

    private func kindTile(_ option: MedicalRecord.Kind) -> some View {
        let isSelected = option == kind

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { kind = option }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: option.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isSelected ? .white : option.color)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? option.color : option.softColor, in: Circle())
                Text(option.shortTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large, style: .continuous)
                    .stroke(isSelected ? option.color : Theme.Colors.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Details

    @ViewBuilder
    private var detailsSection: some View {
        switch kind {
        case .vaccination:
            FormSection(title: "Деталі") {
                FormTextField(label: "Ветклініка", text: $clinic, placeholder: "Необов'язково", icon: "building.2.fill")
                FormTextField(label: "Серія / номер вакцини", text: $serialNumber, placeholder: "Необов'язково", icon: "number")
                    .autocorrectionDisabled()
            }
        case .deworming:
            FormSection(title: "Деталі") {
                FormTextField(label: "Дозування", text: $dosage, placeholder: "1 таблетка", icon: "scalemass.fill")
            }
        case .fleaTreatment:
            FormSection(title: "Деталі") {
                ChipPicker(options: MedicalRecord.TreatmentType.allCases, selection: $treatmentType, title: { $0.title })
                FormTextField(label: "Дозування", text: $dosage, placeholder: "1 піпетка", icon: "scalemass.fill")
            }
        }
    }

    private var reminderFooter: String? {
        guard hasNextDue else { return nil }
        return reminderDaysBefore > 0
            ? "Нагадування прийде за \(reminderDaysBefore) дн. і в день процедури."
            : "Нагадування прийде в день процедури."
    }

    private var selectedIntervalTitle: String? {
        kind.intervalOptions
            .first { months in
                let date = Calendar.current.date(byAdding: .month, value: months, to: dateAdministered) ?? dateAdministered
                return Calendar.current.isDate(date, inSameDayAs: nextDueDate)
            }
            .map(intervalTitle)
    }

    private func intervalTitle(_ months: Int) -> String {
        months % 12 == 0 ? "через \(months / 12) р." : "через \(months) міс."
    }

    private func setNextDue(months: Int) {
        nextDueDate = Calendar.current.date(byAdding: .month, value: months, to: dateAdministered) ?? dateAdministered
    }

    private func save() {
        let target = record ?? MedicalRecord(kind: kind, name: "", dateAdministered: dateAdministered)

        target.kind = kind
        target.name = name.trimmed
        target.dateAdministered = dateAdministered
        target.nextDueDate = hasNextDue ? nextDueDate : nil
        target.notes = notes.nilIfBlank
        target.clinic = kind == .vaccination ? clinic.nilIfBlank : nil
        target.serialNumber = kind == .vaccination ? serialNumber.nilIfBlank : nil
        target.dosage = kind == .vaccination ? nil : dosage.nilIfBlank
        target.treatmentType = kind == .fleaTreatment ? treatmentType : nil
        target.updatedAt = Date()

        if record == nil {
            context.insert(target)
            target.pet = pet
        }
        context.saveChanges()

        // Перший запис з датою — саме час попросити дозвіл на сповіщення
        if hasNextDue && AppSettings.isRemindersEnabled {
            Task {
                if await NotificationManager.shared.requestAuthorization() {
                    await NotificationManager.shared.rescheduleAll(in: context)
                }
            }
        }
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    let container = Persistence.preview
    let pet = try! container.mainContext.fetch(FetchDescriptor<Pet>()).first!
    return MedicalRecordFormView(pet: pet, kind: .vaccination)
        .modelContainer(container)
}
