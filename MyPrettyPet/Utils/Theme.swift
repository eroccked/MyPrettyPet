//
//  Theme.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI

struct Theme {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.black
        static let secondary = Color.gray
        static let accent = Color.blue.opacity(0.8)
        static let background = Color.white
        static let cardBackground = Color.white
        static let shadow = Color.black.opacity(0.1)
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let circle: CGFloat = 999
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let small = ShadowStyle(
            color: Colors.shadow,
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = ShadowStyle(
            color: Colors.shadow,
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = ShadowStyle(
            color: Colors.shadow,
            radius: 12,
            x: 0,
            y: 6
        )
    }
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.Shadow.medium.color,
                   radius: Theme.Shadow.medium.radius,
                   x: Theme.Shadow.medium.x,
                   y: Theme.Shadow.medium.y)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(Theme.Fonts.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.accent)
            .cornerRadius(Theme.CornerRadius.medium)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(Theme.Fonts.headline)
            .foregroundColor(Theme.Colors.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Shadow.small.color,
                   radius: Theme.Shadow.small.radius,
                   x: Theme.Shadow.small.x,
                   y: Theme.Shadow.small.y)
    }
}
