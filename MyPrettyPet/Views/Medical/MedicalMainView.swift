//
//  MedicalMainView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI

struct MedicalMainView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack {
                    Text("Медичні записи")
                        .font(Theme.Fonts.largeTitle)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
