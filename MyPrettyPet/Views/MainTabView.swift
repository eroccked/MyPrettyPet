//
//  MainTabView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент
            Group {
                switch selectedTab {
                case .home:
                    PetListView()
                case .feeding:
                    FeedingMainView()
                case .medical:
                    MedicalMainView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // TabBar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
