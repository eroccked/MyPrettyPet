//
//  MainTabView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//
import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var chrome = AppChrome()
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !chrome.isTabBarHidden {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: chrome.isTabBarHidden)
        .environment(chrome)
        .tint(Theme.Colors.accent)
        .onChange(of: scenePhase) { _, phase in
            // Дані могли змінитися на іншому пристрої — оновлюємо нагадування
            if phase == .active {
                Task { await NotificationManager.shared.rescheduleAll(in: context) }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .modelContainer(Persistence.preview)
}
