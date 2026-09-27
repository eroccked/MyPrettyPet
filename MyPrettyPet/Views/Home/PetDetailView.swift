//
//  PetDetailView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import SwiftData

struct PetDetailView: View {
    let pet: Pet

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppChrome.self) private var chrome

    @State private var showFeedingSheet = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var addingMedicalKind: MedicalRecord.Kind?

    private let heroHeight: CGFloat = 400

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                VStack(alignment: .leading, spacing: 24) {
                    titleRow
                    Divider()
                    infoTiles
                    FeedingSummaryBlock(pet: pet)
                    MedicalSummaryBlock(pet: pet) { addingMedicalKind = $0 }
                    PassportBlock(pet: pet)
                }
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.top, 28)
                .padding(.bottom, 110)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Theme.Colors.cardBackground,
                    in: UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                )
                .padding(.top, -36)
            }
        }
        .scrollIndicators(.hidden)
        .background(Theme.Colors.cardBackground)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            Button {
                showFeedingSheet = true
            } label: {
                Label("Погодувати", systemImage: "fork.knife")
                    .primaryButtonStyle()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Редагувати", systemImage: "square.and.pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Видалити", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .onAppear { chrome.isTabBarHidden = true }
        .onDisappear { chrome.isTabBarHidden = false }
        .sheet(isPresented: $showFeedingSheet) {
            FeedingFormView(pet: pet)
        }
        .sheet(isPresented: $showEditSheet) {
            PetFormView(pet: pet)
        }
        .sheet(item: $addingMedicalKind) { kind in
            MedicalRecordFormView(pet: pet, kind: kind)
        }
        .confirmationDialog("Видалити \(pet.name)?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Видалити", role: .destructive) {
                deletePet()
            }
        } message: {
            Text("Усі записи годування та медичні записи теж буде видалено.")
        }
    }

    // MARK: - Hero

    /// Фото на всю ширину, що розтягується при потягуванні вниз
    private var hero: some View {
        GeometryReader { geometry in
            let pull = max(geometry.frame(in: .scrollView).minY, 0)

            PetPhotoView(photoData: pet.photoData, iconSize: 90)
                .frame(width: geometry.size.width, height: heroHeight + pull)
                .clipped()
                .overlay(alignment: .top) {
                    // Затемнення під статус-бар і кнопки навігації
                    LinearGradient(colors: [.black.opacity(0.45), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 140)
                }
                .offset(y: -pull)
        }
        .frame(height: heroHeight)
    }

    // MARK: - Title

    private var titleRow: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: 8) {
                Text(pet.name)
                    .font(Theme.Fonts.largeTitle)
                    .foregroundColor(Theme.Colors.primary)

                Label(
                    [pet.species, pet.breed].filter { !$0.isEmpty }.joined(separator: " • "),
                    systemImage: "pawprint"
                )
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondary)
            }

            Spacer()

            Text(pet.gender.symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(pet.gender.tint)
                .frame(width: 56, height: 56)
                .background(pet.gender.softColor, in: Circle())
                .accessibilityLabel(pet.gender.title)
        }
    }

    // MARK: - Info Tiles

    private var infoTiles: some View {
        HStack(spacing: 12) {
            InfoTile(label: "Стать", value: pet.gender.title)
            InfoTile(label: "Вік", value: pet.ageText)
            InfoTile(label: "Колір", value: pet.furColor.isEmpty ? "—" : pet.furColor)
        }
    }

    // MARK: - Delete

    private func deletePet() {
        dismiss()
        // Видаляємо після закриття екрана, щоб він не звертався до видаленого об'єкта
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            context.delete(pet)
            context.saveChanges()
        }
    }
}

// MARK: - Gender Style
private extension Pet.Gender {
    var symbol: String {
        switch self {
        case .male: "♂"
        case .female: "♀"
        case .unknown: "?"
        }
    }

    var tint: Color {
        switch self {
        case .male: Theme.Colors.blue
        case .female: Theme.Colors.accent
        case .unknown: Theme.Colors.secondary
        }
    }

    var softColor: Color {
        switch self {
        case .male: Theme.Colors.lavenderSoft
        case .female: Theme.Colors.pinkSoft
        case .unknown: Theme.Colors.background
        }
    }
}

// MARK: - Info Tile
struct InfoTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(Theme.Fonts.footnote)
                .foregroundColor(Theme.Colors.secondary)
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .outlinedStyle(cornerRadius: Theme.CornerRadius.large)
    }
}

// MARK: - Feeding Summary
struct FeedingSummaryBlock: View {
    let pet: Pet

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Годування")

            HStack(spacing: 14) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
                    .frame(width: 52, height: 52)
                    .background(Theme.Colors.pinkSoft, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Сьогодні: \(pet.todayFeedingCount)")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(Theme.Colors.primary)
                    Text(pet.lastFeeding.map { "Востаннє: \($0.foodName), \($0.dateTime.timeAgo().lowercased())" } ?? "Ще не годували")
                        .font(Theme.Fonts.footnote)
                        .foregroundColor(Theme.Colors.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                NavigationLink {
                    FeedingHistoryScreen(pet: pet)
                } label: {
                    RoundIconLabel(systemImage: "list.bullet")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Історія годування")
            }
            .padding(14)
            .outlinedStyle()
        }
    }
}

// MARK: - Medical Summary
struct MedicalSummaryBlock: View {
    let pet: Pet
    let onAdd: (MedicalRecord.Kind) -> Void

    var body: some View {
        let upcoming = Array(pet.upcomingReminders.prefix(3))

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(title: "Медичне")
                Spacer()
                NavigationLink {
                    MedicalRecordsScreen(pet: pet)
                } label: {
                    Text("Усі записи")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
            }

            VStack(spacing: 0) {
                if upcoming.isEmpty {
                    HStack(spacing: 14) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.Colors.green)
                            .frame(width: 52, height: 52)
                            .background(Theme.Colors.mintSoft, in: Circle())
                        Text("Найближчим часом процедур немає")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(Theme.Colors.secondary)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 14)
                } else {
                    ForEach(upcoming) { record in
                        MedicalRecordRow(record: record, showsDueDate: true)
                            .padding(.vertical, 12)
                        if record.id != upcoming.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .outlinedStyle()

            HStack(spacing: 8) {
                ForEach(MedicalRecord.Kind.allCases) { kind in
                    Button {
                        onAdd(kind)
                    } label: {
                        Label(kind.shortTitle, systemImage: "plus")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(kind.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(kind.softColor, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Passport
struct PassportBlock: View {
    let pet: Pet

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Паспорт")

            VStack(spacing: 12) {
                InfoRow(icon: "calendar", label: "Дата народження", value: pet.dateOfBirth.toMediumString())

                if !pet.breed.isEmpty {
                    Divider()
                    InfoRow(icon: "pawprint.fill", label: "Порода", value: pet.breed)
                }

                if let microchipNumber = pet.microchipNumber {
                    Divider()
                    InfoRow(icon: "barcode", label: "Мікрочіп", value: microchipNumber)
                    if let microchipLocation = pet.microchipLocation {
                        InfoRow(icon: "", label: "Розташування", value: microchipLocation, isIndented: true)
                    }
                    if let microchipDate = pet.microchipDate {
                        InfoRow(icon: "", label: "Дата", value: microchipDate.toMediumString(), isIndented: true)
                    }
                }

                if let tattooNumber = pet.tattooNumber {
                    Divider()
                    InfoRow(icon: "number", label: "Тату", value: tattooNumber)
                    if let tattooDate = pet.tattooDate {
                        InfoRow(icon: "", label: "Дата", value: tattooDate.toMediumString(), isIndented: true)
                    }
                }
            }
            .padding(14)
            .outlinedStyle()
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var isIndented: Bool = false

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Group {
                if isIndented {
                    Color.clear
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .frame(width: 22, height: 22)

            Text(label)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.Colors.primary)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Preview
#Preview {
    let container = Persistence.preview
    let pet = try! container.mainContext.fetch(FetchDescriptor<Pet>()).first!
    return NavigationStack {
        PetDetailView(pet: pet)
    }
    .modelContainer(container)
    .environment(AppChrome())
}
