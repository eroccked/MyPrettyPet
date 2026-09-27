//
//  CustomTabBar.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import Observation

enum TabItem: CaseIterable {
    case home, feeding, medical, settings

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .feeding: "fork.knife"
        case .medical: "cross.case.fill"
        case .settings: "gearshape.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Головна"
        case .feeding: "Годування"
        case .medical: "Медичне"
        case .settings: "Налаштування"
        }
    }
}

/// Плаваюча капсула: активна вкладка — біла «пігулка» з назвою, решта — лише іконки
struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                let isSelected = tab == selectedTab

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .foregroundColor(isSelected ? Theme.Colors.accent : Theme.Colors.secondary)
                    .padding(.horizontal, isSelected ? 18 : 0)
                    .frame(maxWidth: isSelected ? nil : .infinity)
                    .frame(height: 50)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Theme.Colors.cardBackground)
                                .shadow(color: Theme.Colors.shadow, radius: 6, x: 0, y: 2)
                                .matchedGeometryEffect(id: "selectedTab", in: namespace)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(6)
        .background(Theme.Colors.tabBarBackground, in: Capsule())
        .shadow(color: Color.black.opacity(0.1), radius: 18, x: 0, y: 8)
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.bottom, 4)
    }
}

// MARK: - App Chrome
/// Дозволяє екранам ховати таббар (напр. картка тварини з власною кнопкою внизу)
@Observable
final class AppChrome {
    var isTabBarHidden = false
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
    }
    .background(Theme.Colors.background)
}
