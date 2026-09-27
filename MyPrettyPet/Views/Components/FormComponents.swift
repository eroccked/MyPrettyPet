//
//  FormComponents.swift
//  MyPrettyPet
//
//  Спільні елементи форм у стилі застосунку: картки-секції, поля, «чіпи».
//

import SwiftUI

// MARK: - Form Screen
/// Екран форми в шторці: картки на світлому фоні і велика кнопка збереження внизу
struct FormScreen<Content: View>: View {
    let title: String
    let saveTitle: String
    let canSave: Bool
    let onSave: () -> Void
    @ViewBuilder var content: Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    content
                }
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.Colors.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .accessibilityLabel("Скасувати")
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: onSave) {
                    Text(saveTitle)
                        .primaryButtonStyle()
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.45)
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [Theme.Colors.background.opacity(0), Theme.Colors.background],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            }
        }
        .tint(Theme.Colors.accent)
    }
}

// MARK: - Form Section
/// Заголовок над карткою і (необов'язково) підказка під нею
struct FormSection<Content: View>: View {
    let title: String?
    var footer: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.Colors.secondary)
                    .padding(.leading, 4)
            }

            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()

            if let footer {
                Text(footer)
                    .font(Theme.Fonts.footnote)
                    .foregroundColor(Theme.Colors.secondary)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Text Field
struct FormTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String?
    var axis: Axis = .horizontal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.Colors.secondary)

            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                        .frame(width: 20)
                }
                TextField(placeholder, text: $text, axis: axis)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.primary)
                    .lineLimit(axis == .vertical ? 1...5 : 1...1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Theme.Colors.fieldBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium, style: .continuous))
        }
    }
}

// MARK: - Row
/// Рядок «підпис — елемент праворуч» (дата, перемикач тощо)
struct FormRow<Trailing: View>: View {
    let label: String
    var icon: String?
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
                    .frame(width: 20)
            }
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(Theme.Colors.primary)
            Spacer(minLength: 8)
            trailing
        }
    }
}

// MARK: - Toggle
struct FormToggle: View {
    let label: String
    var icon: String?
    @Binding var isOn: Bool

    var body: some View {
        FormRow(label: label, icon: icon) {
            Toggle("", isOn: $isOn.animation())
                .labelsHidden()
                .tint(Theme.Colors.accent)
        }
    }
}

// MARK: - Chip Picker
/// Вибір одного значення з «чіпів»
struct ChipPicker<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String
    var icon: ((Value) -> String)?
    var tint: ((Value) -> Color)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let isSelected = option == selection
                    let color = tint?(option) ?? Theme.Colors.accent

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selection = option }
                    } label: {
                        HStack(spacing: 6) {
                            if let icon {
                                Image(systemName: icon(option))
                            }
                            Text(title(option))
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Theme.Colors.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isSelected ? color : Theme.Colors.fieldBackground, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Suggestion Chips
/// Швидкі підказки: натиснув — значення підставилось у поле
struct SuggestionChips: View {
    let options: [String]
    var selected: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let isSelected = option == selected
                    Button {
                        onSelect(option)
                    } label: {
                        Text(option)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected ? .white : Theme.Colors.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isSelected ? Theme.Colors.accent : Theme.Colors.pinkSoft, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Form Header
/// Аватар тварини і підпис над формою
struct FormPetHeader: View {
    let pet: Pet
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            PetAvatar(photoData: pet.photoData, size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.primary)
                Text(subtitle)
                    .font(Theme.Fonts.footnote)
                    .foregroundColor(Theme.Colors.secondary)
            }
            Spacer()
        }
    }
}
