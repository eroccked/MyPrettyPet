//
//  Theme.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import UIKit

struct Theme {

    // MARK: - Colors
    struct Colors {
        // Текст
        static let primary = Color(light: 0x2A2226, dark: 0xF5EFF1)
        static let secondary = Color(light: 0x8C7F84, dark: 0xA89CA1)

        // Акценти
        static let accent = Color(hex: 0xC4506F)
        static let green = Color(hex: 0x4FA889)
        static let blue = Color(hex: 0x6D86D8)
        static let orange = Color(hex: 0xE39A5B)
        static let purple = Color(hex: 0x9C7FD0)

        // Шампань-золото, як лінія на іконці
        static let gold = Color(hex: 0xE2BE96)
        /// Золото для тексту на світлому фоні (контрастніше)
        static let goldText = Color(light: 0xA27A48, dark: 0xE2BE96)
        static let goldSoft = Color(light: 0xF6EBDD, dark: 0x3A2E22)

        // Шапка — глибокий сливовий, як фон іконки
        static let header = Color(light: 0x7E4F5A, dark: 0x4A2F36)
        static let headerDeep = Color(light: 0x5A3640, dark: 0x36222A)

        // Поверхні
        static let background = Color(light: 0xF8F4F5, dark: 0x131012)
        static let cardBackground = Color(light: 0xFFFFFF, dark: 0x1F1B1D)
        static let fieldBackground = Color(light: 0xF6F0F2, dark: 0x2A2427)
        static let tabBarBackground = Color(light: 0xF0E7E9, dark: 0x2A2427)
        static let border = Color(light: 0xEEE4E7, dark: 0x322B2E)
        static let shadow = Color(hex: 0x6B3A48).opacity(0.08)

        // Пастельні підкладки
        static let pinkSoft = Color(light: 0xF8E4E9, dark: 0x3B252C)
        static let mintSoft = Color(light: 0xE0F1EA, dark: 0x1F3129)
        static let peachSoft = Color(light: 0xFBEBDD, dark: 0x3A2D22)
        static let lavenderSoft = Color(light: 0xE7E9F8, dark: 0x272A3D)
    }

    // MARK: - Fonts
    struct Fonts {
        static let logo = Font.system(size: 28, weight: .heavy, design: .rounded)
        static let largeTitle = Font.system(size: 30, weight: .bold)
        static let title = Font.system(size: 26, weight: .bold)
        static let title2 = Font.system(size: 22, weight: .bold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let callout = Font.system(size: 16, weight: .regular)
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let footnote = Font.system(size: 13, weight: .regular)
        static let caption = Font.system(size: 12, weight: .medium)
    }

    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let screen: CGFloat = 20
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 14
        static let large: CGFloat = 18
        static let card: CGFloat = 22
        static let extraLarge: CGFloat = 32
    }

    // MARK: - Shadow
    struct Shadow {
        static let small = ShadowStyle(color: Colors.shadow, radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: Colors.shadow, radius: 10, x: 0, y: 4)
        static let large = ShadowStyle(color: Colors.shadow, radius: 16, x: 0, y: 8)
    }

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Hex Colors
extension UIColor {
    nonisolated convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    nonisolated init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// Колір, що змінюється для світлої і темної теми
    nonisolated init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

// MARK: - View Extensions
extension View {
    /// Біла картка з тонкою рамкою і м'якою тінню
    func cardStyle(cornerRadius: CGFloat = Theme.CornerRadius.card) -> some View {
        self
            .background(Theme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
            .shadow(color: Theme.Shadow.medium.color,
                    radius: Theme.Shadow.medium.radius,
                    x: Theme.Shadow.medium.x,
                    y: Theme.Shadow.medium.y)
    }

    /// Блок лише з рамкою, без тіні — як на картці тварини
    func outlinedStyle(cornerRadius: CGFloat = Theme.CornerRadius.card) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
    }

    func primaryButtonStyle() -> some View {
        self
            .font(Theme.Fonts.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Theme.Colors.accent, in: Capsule())
            .shadow(color: Theme.Colors.accent.opacity(0.35), radius: 14, x: 0, y: 8)
    }

    /// Сіро-рожева навігаційна панель для вкладених екранів — під колір шапки
    func headerNavigationBar() -> some View {
        self
            .toolbarBackground(Theme.Colors.header, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
