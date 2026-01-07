//
//  CustomTabBar.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "house.fill"
    case feeding = "fork.knife"
    case medical = "cross.case.fill"
    case settings = "gearshape.fill"
    
    var title: String {
        switch self {
        case .home: return "Головна"
        case .feeding: return "Годування"
        case .medical: return "Медичне"
        case .settings: return "Налаштування"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
        )
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.bottom, Theme.Spacing.small)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.secondary)
                
                Text(tab.title)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Preview
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.home))
        }
        .background(Color.gray.opacity(0.1))
    }
}
