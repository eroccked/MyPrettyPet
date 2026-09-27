//
//  PetListView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import SwiftData

struct PetListView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @AppStorage(AppSettings.ownerName) private var ownerName = ""

    @State private var showAddPet = false
    @State private var feedingPet: Pet?
    @State private var medicalTarget: MedicalTarget?
    @State private var pendingAction: QuickAction?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Шапка поза прокруткою, щоб її фон заходив під статус-бар
                AppHeader(title: "My Pretty Pet", subtitle: greeting) {
                    HeaderIconButton(systemImage: "plus", accessibilityTitle: "Додати тварину") {
                        showAddPet = true
                    }
                }
                .zIndex(1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        if pets.isEmpty {
                            EmptyPetsCard { showAddPet = true }
                        } else {
                            QuickActionsRow(onSelect: handle)
                            petsSection
                            remindersSection
                            todayFeedingSection
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, Theme.Spacing.large)
                }
                .scrollIndicators(.hidden)
            }
            .background(Theme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Pet.self) { pet in
                PetDetailView(pet: pet)
            }
            .sheet(isPresented: $showAddPet) {
                PetFormView()
            }
            .sheet(item: $feedingPet) { pet in
                FeedingFormView(pet: pet)
            }
            .sheet(item: $medicalTarget) { target in
                MedicalRecordFormView(pet: target.pet, kind: target.kind)
            }
            .confirmationDialog(pendingAction?.title ?? "", isPresented: isChoosingPet, titleVisibility: .visible) {
                ForEach(pets) { pet in
                    Button(pet.name) {
                        if let action = pendingAction {
                            perform(action, for: pet)
                        }
                    }
                }
            } message: {
                Text("Оберіть тварину")
            }
        }
    }

    private var greeting: String {
        ownerName.trimmed.isEmpty ? "Турбота про улюбленців" : "Привіт, \(ownerName.trimmed)!"
    }

    // MARK: - Quick Actions

    private var isChoosingPet: Binding<Bool> {
        Binding(
            get: { pendingAction != nil },
            set: { if !$0 { pendingAction = nil } }
        )
    }

    private func handle(_ action: QuickAction) {
        if action == .addPet {
            showAddPet = true
        } else if pets.count == 1, let pet = pets.first {
            perform(action, for: pet)
        } else {
            pendingAction = action
        }
    }

    private func perform(_ action: QuickAction, for pet: Pet) {
        pendingAction = nil
        if let kind = action.medicalKind {
            medicalTarget = MedicalTarget(pet: pet, kind: kind)
        } else if action == .feed {
            feedingPet = pet
        }
    }

    // MARK: - Pets

    private var petsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Мої улюбленці")
                .padding(.horizontal, Theme.Spacing.screen)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(pets) { pet in
                        PetPhotoCard(pet: pet) { feedingPet = pet }
                    }
                    AddPetCard { showAddPet = true }
                }
                .padding(.horizontal, Theme.Spacing.screen)
            }
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        let reminders = pets
            .flatMap { pet in pet.upcomingReminders.map { PetReminder(pet: pet, record: $0) } }
            .sorted { ($0.record.nextDueDate ?? .distantFuture) < ($1.record.nextDueDate ?? .distantFuture) }

        return VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Найближчі процедури")
                .padding(.horizontal, Theme.Spacing.screen)

            if reminders.isEmpty {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Theme.Colors.green)
                        .frame(width: 48, height: 48)
                        .background(Theme.Colors.mintSoft, in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Усе під контролем")
                            .font(Theme.Fonts.headline)
                        Text("Найближчі 30 днів процедур немає")
                            .font(Theme.Fonts.footnote)
                            .foregroundColor(Theme.Colors.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .cardStyle()
                .padding(.horizontal, Theme.Spacing.screen)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(reminders) { reminder in
                            NavigationLink(value: reminder.pet) {
                                ReminderCard(record: reminder.record, petName: reminder.pet.name)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.screen)
                }
            }
        }
    }

    // MARK: - Today Feeding

    private var todayFeedingSection: some View {
        let feedings = pets
            .flatMap { pet in
                (pet.feedingRecords ?? [])
                    .filter { Calendar.current.isDateInToday($0.dateTime) }
                    .map { PetFeeding(pet: pet, record: $0) }
            }
            .sorted { $0.record.dateTime > $1.record.dateTime }

        return VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Сьогодні")

            VStack(spacing: 0) {
                if feedings.isEmpty {
                    VStack(spacing: 12) {
                        Text("Сьогодні ще нікого не годували")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(Theme.Colors.secondary)
                        Button {
                            handle(.feed)
                        } label: {
                            Label("Погодувати", systemImage: "fork.knife")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Theme.Colors.accent)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Theme.Colors.pinkSoft, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(feedings) { item in
                        HStack(spacing: 12) {
                            PetAvatar(photoData: item.pet.photoData, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.pet.name)
                                    .font(.system(size: 15, weight: .semibold))
                                Text([item.record.foodName, item.record.portion].filter { !$0.isEmpty }.joined(separator: " • "))
                                    .font(Theme.Fonts.footnote)
                                    .foregroundColor(Theme.Colors.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(item.record.dateTime.toString(format: "HH:mm"))
                                .font(.system(size: 15, weight: .semibold))
                                .monospacedDigit()
                                .foregroundColor(Theme.Colors.accent)
                        }
                        .padding(.vertical, 10)

                        if item.id != feedings.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .cardStyle()
        }
        .padding(.horizontal, Theme.Spacing.screen)
    }
}

// MARK: - Helper Types
private struct MedicalTarget: Identifiable {
    let pet: Pet
    let kind: MedicalRecord.Kind
    var id: String { "\(pet.id)-\(kind.rawValue)" }
}

private struct PetReminder: Identifiable {
    let pet: Pet
    let record: MedicalRecord
    var id: UUID { record.id }
}

private struct PetFeeding: Identifiable {
    let pet: Pet
    let record: FeedingRecord
    var id: UUID { record.id }
}

enum QuickAction: CaseIterable, Identifiable {
    case feed, vaccination, deworming, flea, addPet

    var id: Self { self }

    var title: String {
        switch self {
        case .feed: "Погодувати"
        case .vaccination: "Щеплення"
        case .deworming: "Глистування"
        case .flea: "Від бліх"
        case .addPet: "Нова тварина"
        }
    }

    var icon: String {
        switch self {
        case .feed: "fork.knife"
        case .vaccination: MedicalRecord.Kind.vaccination.icon
        case .deworming: MedicalRecord.Kind.deworming.icon
        case .flea: MedicalRecord.Kind.fleaTreatment.icon
        case .addPet: "plus"
        }
    }

    var tint: Color {
        switch self {
        case .feed: Theme.Colors.accent
        case .vaccination: MedicalRecord.Kind.vaccination.color
        case .deworming: MedicalRecord.Kind.deworming.color
        case .flea: MedicalRecord.Kind.fleaTreatment.color
        case .addPet: Theme.Colors.lemonText
        }
    }

    var softColor: Color {
        switch self {
        case .feed: Theme.Colors.pinkSoft
        case .vaccination: MedicalRecord.Kind.vaccination.softColor
        case .deworming: MedicalRecord.Kind.deworming.softColor
        case .flea: MedicalRecord.Kind.fleaTreatment.softColor
        case .addPet: Theme.Colors.lemonSoft
        }
    }

    var medicalKind: MedicalRecord.Kind? {
        switch self {
        case .vaccination: .vaccination
        case .deworming: .deworming
        case .flea: .fleaTreatment
        case .feed, .addPet: nil
        }
    }
}

// MARK: - Quick Actions Row
struct QuickActionsRow: View {
    let onSelect: (QuickAction) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(QuickAction.allCases) { action in
                    Button {
                        onSelect(action)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: action.icon)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(action.tint)
                                .frame(width: 64, height: 64)
                                .background(action.softColor, in: Circle())
                            Text(action.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.Colors.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(width: 84)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.screen - 4)
        }
    }
}

// MARK: - Pet Photo Card
struct PetPhotoCard: View {
    let pet: Pet
    let onFeed: () -> Void

    private let width: CGFloat = 176

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(value: pet) {
                PetPhotoView(photoData: pet.photoData, iconSize: 48)
                    .frame(width: width, height: 204)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.card, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.card, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if let badge = badge {
                            Text(badge.text)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(badge.isAlert ? .white : Theme.Colors.lemonText)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(badge.isAlert ? Color.red.opacity(0.9) : Theme.Colors.lemonSoft, in: Capsule())
                                .padding(10)
                        }
                    }
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottomTrailing) {
                Button(action: onFeed) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial, in: Circle())
                        .background(Color.black.opacity(0.25), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Погодувати \(pet.name)")
                .padding(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Theme.Colors.primary)
                    .lineLimit(1)

                Text([pet.species, pet.breed].filter { !$0.isEmpty }.joined(separator: " • "))
                    .font(Theme.Fonts.footnote)
                    .foregroundColor(Theme.Colors.secondary)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label("\(pet.todayFeedingCount)", systemImage: "fork.knife")
                        .foregroundColor(Theme.Colors.accent)
                    Label(pet.ageText, systemImage: "birthday.cake.fill")
                        .foregroundColor(Theme.Colors.star)
                        .lineLimit(1)
                }
                .font(.system(size: 12, weight: .semibold))
                .labelStyle(CompactLabelStyle())
            }
            .padding(.horizontal, 4)
        }
        .frame(width: width)
    }

    private var badge: (text: String, isAlert: Bool)? {
        if pet.hasOverdueReminders {
            return ("Прострочено", true)
        }
        if let next = pet.upcomingReminders.first, let dueText = next.dueText {
            return ("\(next.kind.shortTitle): \(dueText.lowercased())", false)
        }
        return nil
    }
}

/// Іконка і текст впритул, текст основним кольором
private struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
                .foregroundColor(Theme.Colors.primary)
        }
    }
}

// MARK: - Add Pet Card
struct AddPetCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
                    .frame(width: 52, height: 52)
                    .background(Theme.Colors.pinkSoft, in: Circle())
                Text("Додати")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.primary)
            }
            .frame(width: 120, height: 204)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.card, style: .continuous)
                    .strokeBorder(Theme.Colors.border, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reminder Card
/// Кольорова картка процедури, як «Our services» на зразку
struct ReminderCard: View {
    let record: MedicalRecord
    let petName: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [record.kind.color, record.kind.color.opacity(0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: record.kind.icon)
                .font(.system(size: 84, weight: .bold))
                .foregroundColor(.white.opacity(0.18))
                .rotationEffect(.degrees(-15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: 16, y: 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.kind.title)
                    .font(.system(size: 18, weight: .bold))
                Text(record.name)
                    .font(.system(size: 14, weight: .medium))
                    .opacity(0.9)
                    .lineLimit(1)

                Spacer()

                Text(petName)
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.9)

                if let dueText = record.dueText {
                    Text(dueText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor((record.daysUntilDue ?? 0) < 0 ? .red : record.kind.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white, in: Capsule())
                }
            }
            .foregroundColor(.white)
            .padding(16)
        }
        .frame(width: 204, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Empty State
struct EmptyPetsCard: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 96, height: 96)
                .background(Theme.Colors.pinkSoft, in: Circle())

            Text("Додайте першого улюбленця")
                .font(Theme.Fonts.title2)
                .multilineTextAlignment(.center)

            Text("Записуйте годування, щеплення й обробки — і отримуйте нагадування вчасно.")
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondary)
                .multilineTextAlignment(.center)

            Button(action: onAdd) {
                Text("Додати тварину")
                    .primaryButtonStyle()
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(24)
        .cardStyle()
        .padding(.horizontal, Theme.Spacing.screen)
    }
}

// MARK: - Preview
#Preview {
    PetListView()
        .modelContainer(Persistence.preview)
        .environment(AppChrome())
}
