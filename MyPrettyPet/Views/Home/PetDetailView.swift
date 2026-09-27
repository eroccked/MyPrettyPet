//
//  PetDetailView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI

struct PetDetailView: View {
    let pet: Pet
    @StateObject private var viewModel: PetViewModel
    @State private var showFeedingSheet = false
    @State private var showEditSheet = false
    
    init(pet: Pet) {
        self.pet = pet
        self._viewModel = StateObject(wrappedValue: PetViewModel(pet: pet))
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    // Фото та основна інфа
                    PetHeaderSection(pet: viewModel.pet ?? pet)
                    
                    // Швидкі дії
                    QuickActionsSection(
                        onFeed: { showFeedingSheet = true },
                        onEdit: { showEditSheet = true }
                    )
                    
                    // Статистика годування
                    FeedingStatsSection(
                        todayCount: viewModel.todayFeedingCount,
                        lastFeeding: viewModel.lastFeeding
                    )
                    
                    // Паспортні дані
                    PassportInfoSection(pet: viewModel.pet ?? pet)
                    
                    // Медичні нагадування
                    MedicalRemindersSection(pet: viewModel.pet ?? pet)
                    
                    Spacer(minLength: 100)
                }
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFeedingSheet) {
            QuickFeedingSheet(pet: viewModel.pet ?? pet)
        }
        .sheet(isPresented: $showEditSheet) {
            AddPetView()
        }
        .onAppear {
            viewModel.loadPetData(for: pet)
        }
    }
}

// MARK: - Pet Header Section
struct PetHeaderSection: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Фото
            if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 4)
                    )
                    .shadow(color: Theme.Shadow.medium.color,
                           radius: Theme.Shadow.medium.radius,
                           x: Theme.Shadow.medium.x,
                           y: Theme.Shadow.medium.y)
            } else {
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.Colors.accent)
                    )
            }
            
            // Основна інфа
            VStack(spacing: 8) {
                Text(pet.name)
                    .font(Theme.Fonts.largeTitle)
                    .foregroundColor(Theme.Colors.primary)
                
                HStack(spacing: 4) {
                    Text(pet.species)
                    Text("•")
                    Text(petAge(pet.dateOfBirth))
                    Text("•")
                    Text(pet.gender.rawValue)
                }
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.secondary)
                
                Text(pet.breed)
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(Theme.Colors.secondary)
            }
        }
        .padding(.top, Theme.Spacing.large)
    }
    
    private func petAge(_ birthDate: Date) -> String {
        let age = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        
        if let years = age.year, years > 0 {
            if let months = age.month, months > 0 {
                return "\(years) р. \(months) міс."
            }
            return "\(years) р."
        } else if let months = age.month, months > 0 {
            return "\(months) міс."
        }
        return "Новонароджений"
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    let onFeed: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Погодувати
            Button(action: onFeed) {
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 24))
                    Text("Погодувати")
                        .font(Theme.Fonts.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
                .background(Theme.Colors.accent)
                .cornerRadius(Theme.CornerRadius.medium)
            }
            
            // Редагувати
            Button(action: onEdit) {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24))
                    Text("Редагувати")
                        .font(Theme.Fonts.headline)
                }
                .foregroundColor(Theme.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.medium)
                .shadow(color: Theme.Shadow.small.color,
                       radius: Theme.Shadow.small.radius)
            }
        }
        .padding(.horizontal, Theme.Spacing.medium)
    }
}

// MARK: - Feeding Stats Section
struct FeedingStatsSection: View {
    let todayCount: Int
    let lastFeeding: FeedingRecord?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack {
                Text("Годування сьогодні")
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.primary)
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.medium)
            
            HStack(spacing: Theme.Spacing.medium) {
                // Кількість сьогодні
                StatCard(
                    icon: "fork.knife",
                    value: "\(todayCount)",
                    label: "разів сьогодні",
                    color: Theme.Colors.accent
                )
                
                // Останнє годування
                if let lastFeeding = lastFeeding {
                    StatCard(
                        icon: "clock",
                        value: timeAgo(lastFeeding.dateTime),
                        label: "востаннє",
                        color: .green
                    )
                } else {
                    StatCard(
                        icon: "clock",
                        value: "Немає",
                        label: "записів",
                        color: .gray
                    )
                }
            }
            .padding(.horizontal, Theme.Spacing.medium)
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours) год"
        } else if minutes > 0 {
            return "\(minutes) хв"
        } else {
            return "Щойно"
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.Fonts.title)
                .foregroundColor(Theme.Colors.primary)
            
            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundColor(Theme.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.medium)
        .cardStyle()
    }
}

// MARK: - Passport Info Section
struct PassportInfoSection: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack {
                Text("Паспортні дані")
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.primary)
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.medium)
            
            VStack(spacing: Theme.Spacing.small) {
                InfoRow(icon: "paintpalette.fill", label: "Колір шерсті", value: pet.furColor)
                
                if let microchipNumber = pet.microchipNumber {
                    Divider()
                    InfoRow(icon: "barcode", label: "Мікрочіп", value: microchipNumber)
                    
                    if let microchipLocation = pet.microchipLocation {
                        InfoRow(icon: "location.fill", label: "Розташування", value: microchipLocation, isIndented: true)
                    }
                }
                
                if let tattooNumber = pet.tattooNumber {
                    Divider()
                    InfoRow(icon: "number", label: "Тату", value: tattooNumber)
                }
            }
            .padding(Theme.Spacing.medium)
            .cardStyle()
            .padding(.horizontal, Theme.Spacing.medium)
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
            if !isIndented {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.accent)
                    .frame(width: 20)
            } else {
                Spacer()
                    .frame(width: 20)
            }
            
            Text(label)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondary)
            
            Spacer()
            
            Text(value)
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.primary)
        }
    }
}

// MARK: - Medical Reminders Section
struct MedicalRemindersSection: View {
    let pet: Pet
    @State private var showMedicalView = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack {
                Text("Медичні нагадування")
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.primary)
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.medium)
            
            Button(action: {
                showMedicalView = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.red)
                            Text("Медичні записи")
                                .font(Theme.Fonts.headline)
                                .foregroundColor(Theme.Colors.primary)
                        }
                        
                        Text("Переглянути всі щеплення, глистування та обробки")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(Theme.Colors.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.Colors.secondary)
                }
                .padding(Theme.Spacing.medium)
                .cardStyle()
                .padding(.horizontal, Theme.Spacing.medium)
            }
        }
        .sheet(isPresented: $showMedicalView) {
            MedicalDetailView(pet: pet)
        }
    }
}

// MARK: - Medical Detail View (Заглушка)
struct MedicalDetailView: View {
    let pet: Pet
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    Text("Медичні записи для \(pet.name)")
                        .font(Theme.Fonts.title)
                    
                    Text("Тут буде історія:")
                        .padding(.top)
                    Text("• Щеплення")
                    Text("• Глистування")
                    Text("• Обробка від бліх")
                }
            }
            .navigationTitle("Медичні записи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрити") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PetDetailView(pet: Pet(
                name: "Мурчик",
                species: "Кіт",
                breed: "Британець",
                gender: .male,
                dateOfBirth: Date(),
                furColor: "Сірий",
                ownerID: "preview"
            ))
        }
    }
}
