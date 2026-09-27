//
//  MyPrettyPetApp.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import SwiftUI
import SwiftData

@main
struct MyPrettyPetApp: App {
    private let container = Persistence.makeContainer()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}
