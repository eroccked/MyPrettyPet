//
//  PetComponents.swift
//  MyPrettyPet
//

import SwiftUI

// MARK: - App Header
/// Темна шапка із заокругленим нижнім кутом
struct AppHeader<Trailing: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var trailing: Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(title)
                    .font(Theme.Fonts.logo)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                HStack(spacing: 10) {
                    trailing
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.2), in: Capsule())
            }
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(bottomTrailingRadius: 36, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Theme.Colors.header, Theme.Colors.headerDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)
        }
    }
}

extension AppHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

// MARK: - Header Icon Button
/// Кругла напівпрозора кнопка для темної шапки
struct HeaderIconLabel: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 46, height: 46)
            .background(.white.opacity(0.2), in: Circle())
    }
}

struct HeaderIconButton: View {
    let systemImage: String
    let accessibilityTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HeaderIconLabel(systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityTitle)
    }
}

// MARK: - Round Icon (світлий фон)
struct RoundIconLabel: View {
    let systemImage: String
    var tint: Color = Theme.Colors.primary

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(tint)
            .frame(width: 46, height: 46)
            .background(Theme.Colors.background, in: Circle())
    }
}

// MARK: - Section Title
struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(Theme.Fonts.title2)
            .foregroundColor(Theme.Colors.primary)
    }
}

// MARK: - Pet Photo
/// Фото тварини або пастельна заглушка з лапкою
struct PetPhotoView: View {
    let photoData: Data?
    var iconSize: CGFloat = 44

    var body: some View {
        if let photoData, let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: [Theme.Colors.pinkSoft, Theme.Colors.lavenderSoft],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "pawprint.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(Theme.Colors.accent.opacity(0.45))
            }
        }
    }
}

// MARK: - Pet Avatar
struct PetAvatar: View {
    let photoData: Data?
    var size: CGFloat = 60

    var body: some View {
        PetPhotoView(photoData: photoData, iconSize: size * 0.4)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

// MARK: - Pet Selector
/// Горизонтальний перемикач тварин для вкладок «Годування» і «Медичне»
struct PetSelector: View {
    let pets: [Pet]
    let selectedPet: Pet
    let onSelect: (Pet) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(pets) { pet in
                    let isSelected = pet.id == selectedPet.id
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { onSelect(pet) }
                    } label: {
                        HStack(spacing: 8) {
                            PetAvatar(photoData: pet.photoData, size: 30)
                            Text(pet.name)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .padding(.vertical, 6)
                        .padding(.leading, 6)
                        .padding(.trailing, 14)
                        .foregroundColor(isSelected ? .white : Theme.Colors.primary)
                        .background(isSelected ? Theme.Colors.header : Theme.Colors.cardBackground, in: Capsule())
                        .overlay(Capsule().stroke(isSelected ? Color.clear : Theme.Colors.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - No Pets
struct NoPetsView: View {
    var body: some View {
        ContentUnavailableView(
            "Немає тварин",
            systemImage: "pawprint.circle",
            description: Text("Спершу додайте улюбленця на вкладці «Головна»")
        )
        .frame(maxHeight: .infinity)
    }
}
