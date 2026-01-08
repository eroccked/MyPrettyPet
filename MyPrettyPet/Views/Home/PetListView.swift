//
//  PetListView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel = PetListViewModel()
    @State private var showAddPet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.pets.isEmpty {
                        EmptyPetsView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Theme.Spacing.medium) {
                                ForEach(viewModel.pets) { pet in
                                    PetCardWithFeeding(pet: pet)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.medium)
                            .padding(.top, Theme.Spacing.medium)
                            .padding(.bottom, 100) // Відступ для TabBar
                        }
                    }
                }
            }
            .navigationTitle("My Pretty Pet 🐾")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddPet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .sheet(isPresented: $showAddPet) {
                AddPetView()
            }
            .onAppear {
                viewModel.loadPets()
            }
        }
    }
}

// MARK: - Empty State
struct EmptyPetsView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Theme.Colors.secondary.opacity(0.5))
            
            Text("Немає тварин")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.primary)
            
            Text("Додайте свого улюбленця, щоб почати")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.extraLarge)
        }
    }
}

// MARK: - Pet Card With Feeding
struct PetCardWithFeeding: View {
    let pet: Pet
    @State private var showFeedingSheet = false
    @State private var showPetDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Основна інформація (клікабельна)
            Button(action: {
                showPetDetail = true
            }) {
                HStack(spacing: Theme.Spacing.medium) {
                    // Фото
                    if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Theme.Colors.accent.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Theme.Colors.accent)
                            )
                    }
                    
                    // Інформація
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pet.name)
                            .font(Theme.Fonts.title2)
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("\(pet.species) • \(petAge(pet.dateOfBirth))")
                            .font(Theme.Fonts.subheadline)
                            .foregroundColor(Theme.Colors.secondary)
                        
                        HStack {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 12))
                            Text("Сьогодні: 0 разів") // TODO: реальна статистика
                                .font(Theme.Fonts.caption)
                        }
                        .foregroundColor(Theme.Colors.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.Colors.secondary)
                }
                .padding(Theme.Spacing.medium)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .padding(.horizontal, Theme.Spacing.medium)
            
            // Кнопка годування
            Button(action: {
                showFeedingSheet = true
            }) {
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 20))
                    Text("Погодувати")
                        .font(Theme.Fonts.headline)
                }
                .foregroundColor(Theme.Colors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.small)
            }
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.bottom, Theme.Spacing.small)
        }
        .cardStyle()
        .sheet(isPresented: $showFeedingSheet) {
            QuickFeedingSheet(pet: pet)
        }
        .background(
            NavigationLink(
                destination: PetDetailView(pet: pet),
                isActive: $showPetDetail
            ) {
                EmptyView()
            }
            .hidden()
        )
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

// MARK: - Quick Feeding Sheet
struct QuickFeedingSheet: View {
    let pet: Pet
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedFood: String = ""
    @State private var portion: String = ""
    @State private var notes: String = ""
    @State private var foodTypes: [String] = ["Сухий корм", "Вологий корм", "Натуральна їжа", "Ласощі"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        // Заголовок
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.Colors.accent)
                            
                            Text("Погодувати \(pet.name)")
                                .font(Theme.Fonts.title)
                        }
                        .padding(.top, Theme.Spacing.large)
                        
                        // Вибір їжі
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            Text("Тип їжі")
                                .font(Theme.Fonts.headline)
                                .padding(.horizontal, Theme.Spacing.medium)
                            
                            ForEach(foodTypes, id: \.self) { food in
                                Button(action: {
                                    selectedFood = food
                                }) {
                                    HStack {
                                        Text(food)
                                            .font(Theme.Fonts.body)
                                            .foregroundColor(Theme.Colors.primary)
                                        
                                        Spacer()
                                        
                                        if selectedFood == food {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Theme.Colors.accent)
                                        }
                                    }
                                    .padding(Theme.Spacing.medium)
                                    .background(
                                        selectedFood == food ?
                                        Theme.Colors.accent.opacity(0.1) :
                                        Theme.Colors.cardBackground
                                    )
                                    .cornerRadius(Theme.CornerRadius.medium)
                                }
                                .padding(.horizontal, Theme.Spacing.medium)
                            }
                        }
                        .padding(.vertical, Theme.Spacing.small)
                        
                        // Порція
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Порція")
                                .font(Theme.Fonts.headline)
                            
                            TextField("Наприклад: 100г, 1 миска", text: $portion)
                                .font(Theme.Fonts.body)
                                .padding(Theme.Spacing.medium)
                                .background(Theme.Colors.cardBackground)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                        
                        // Нотатки (опціонально)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Нотатки (опціонально)")
                                .font(Theme.Fonts.headline)
                            
                            TextField("Додаткова інформація", text: $notes)
                                .font(Theme.Fonts.body)
                                .padding(Theme.Spacing.medium)
                                .background(Theme.Colors.cardBackground)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                        
                        // Кнопка зберегти
                        Button(action: {
                            saveFeedingRecord()
                        }) {
                            Text("Зберегти")
                        }
                        .primaryButtonStyle()
                        .disabled(selectedFood.isEmpty || portion.isEmpty)
                        .opacity(selectedFood.isEmpty || portion.isEmpty ? 0.5 : 1.0)
                        .padding(.horizontal, Theme.Spacing.medium)
                        .padding(.bottom, Theme.Spacing.extraLarge)
                    }
                }
            }
            .navigationTitle("Годування")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveFeedingRecord() {
        // TODO: Зберегти запис годування через ViewModel
        print("✅ Збережено годування: \(selectedFood), \(portion)")
        dismiss()
    }
}

// MARK: - Preview
struct PetListView_Previews: PreviewProvider {
    static var previews: some View {
        PetListView()
    }
}
