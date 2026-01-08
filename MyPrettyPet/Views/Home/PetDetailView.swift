//
//  PetDetailView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//


import SwiftUI

struct PetDetailView: View {
    let pet: Pet
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack {
                Text(pet.name)
                    .font(Theme.Fonts.largeTitle)
            }
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
