//
//  PetListView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel = PetListViewModel()
    
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
                                    PetCard(pet: pet)
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
                        // TODO: Додати тварину
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
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

// MARK: - Pet Card
struct PetCard: View {
    let pet: Pet
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Фото
            Circle()
                .fill(Theme.Colors.accent.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Theme.Colors.accent)
                )
            
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
                    Text("Останнє годування: сьогодні")
                        .font(Theme.Fonts.caption)
                }
                .foregroundColor(Theme.Colors.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.Colors.secondary)
        }
        .padding(Theme.Spacing.medium)
        .cardStyle()
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

// MARK: - Preview
struct PetListView_Previews: PreviewProvider {
    static var previews: some View {
        PetListView()
    }
}
