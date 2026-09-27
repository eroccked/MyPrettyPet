//
//  PetFormView.swift
//  MyPrettyPet
//

import SwiftUI
import SwiftData
import PhotosUI

/// Додавання нової тварини (pet == nil) або редагування існуючої
struct PetFormView: View {
    let pet: Pet?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var name: String
    @State private var species: String
    @State private var breed: String
    @State private var gender: Pet.Gender
    @State private var dateOfBirth: Date
    @State private var furColor: String

    @State private var microchipNumber: String
    @State private var microchipLocation: String
    @State private var hasMicrochipDate: Bool
    @State private var microchipDate: Date
    @State private var tattooNumber: String
    @State private var hasTattooDate: Bool
    @State private var tattooDate: Date

    private let speciesSuggestions = ["Кіт", "Собака", "Папуга", "Кролик", "Хом'як", "Черепаха"]

    init(pet: Pet? = nil) {
        self.pet = pet
        _photoData = State(initialValue: pet?.photoData)
        _name = State(initialValue: pet?.name ?? "")
        _species = State(initialValue: pet?.species ?? "")
        _breed = State(initialValue: pet?.breed ?? "")
        _gender = State(initialValue: pet?.gender ?? .unknown)
        _dateOfBirth = State(initialValue: pet?.dateOfBirth ?? Date())
        _furColor = State(initialValue: pet?.furColor ?? "")
        _microchipNumber = State(initialValue: pet?.microchipNumber ?? "")
        _microchipLocation = State(initialValue: pet?.microchipLocation ?? "")
        _hasMicrochipDate = State(initialValue: pet?.microchipDate != nil)
        _microchipDate = State(initialValue: pet?.microchipDate ?? Date())
        _tattooNumber = State(initialValue: pet?.tattooNumber ?? "")
        _hasTattooDate = State(initialValue: pet?.tattooDate != nil)
        _tattooDate = State(initialValue: pet?.tattooDate ?? Date())
    }

    private var isValid: Bool {
        !name.trimmed.isEmpty && !species.trimmed.isEmpty
    }

    var body: some View {
        FormScreen(
            title: pet == nil ? "Нова тварина" : "Редагування",
            saveTitle: pet == nil ? "Додати тварину" : "Зберегти",
            canSave: isValid,
            onSave: save
        ) {
            photoPicker

            FormSection(title: "Основне") {
                FormTextField(label: "Ім'я", text: $name, placeholder: "Мурчик", icon: "pawprint.fill")
                    .textInputAutocapitalization(.words)

                VStack(alignment: .leading, spacing: 10) {
                    FormTextField(label: "Вид", text: $species, placeholder: "Кіт, собака…", icon: "hare.fill")
                    SuggestionChips(options: speciesSuggestions, selected: species.trimmed) { species = $0 }
                }

                FormTextField(label: "Порода", text: $breed, placeholder: "Британська", icon: "rosette")
                FormTextField(label: "Колір шерсті", text: $furColor, placeholder: "Сірий", icon: "paintpalette.fill")
            }

            FormSection(title: "Стать і вік") {
                ChipPicker(options: Pet.Gender.allCases, selection: $gender, title: { $0.title })

                FormRow(label: "Дата народження", icon: "birthday.cake.fill") {
                    DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                }
            }

            FormSection(title: "Мікрочіп") {
                FormTextField(label: "Номер", text: $microchipNumber, placeholder: "900123456789012", icon: "barcode")
                    .keyboardType(.asciiCapable)
                    .autocorrectionDisabled()

                if !microchipNumber.trimmed.isEmpty {
                    FormTextField(label: "Розташування", text: $microchipLocation, placeholder: "Ліва лопатка", icon: "location.fill")
                    FormToggle(label: "Вказати дату чіпування", isOn: $hasMicrochipDate)
                    if hasMicrochipDate {
                        FormRow(label: "Дата", icon: "calendar") {
                            DatePicker("", selection: $microchipDate, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
            }

            FormSection(title: "Татуювання") {
                FormTextField(label: "Номер", text: $tattooNumber, placeholder: "ABC123", icon: "number")
                    .autocorrectionDisabled()

                if !tattooNumber.trimmed.isEmpty {
                    FormToggle(label: "Вказати дату тату", isOn: $hasTattooDate)
                    if hasTattooDate {
                        FormRow(label: "Дата", icon: "calendar") {
                            DatePicker("", selection: $tattooDate, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
            }
        }
        .onChange(of: photoItem) { _, item in
            Task { await loadPhoto(from: item) }
        }
    }

    // MARK: - Photo

    private var photoPicker: some View {
        VStack(spacing: 10) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                PetAvatar(photoData: photoData, size: 120)
                    .overlay(Circle().stroke(Theme.Colors.cardBackground, lineWidth: 4))
                    .shadow(color: Theme.Shadow.medium.color, radius: Theme.Shadow.medium.radius, x: 0, y: 4)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Theme.Colors.accent, in: Circle())
                            .overlay(Circle().stroke(Theme.Colors.background, lineWidth: 3))
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Обрати фото")

            if photoData != nil {
                Button("Видалити фото", role: .destructive) {
                    photoData = nil
                    photoItem = nil
                }
                .font(.system(size: 14, weight: .semibold))
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        let resized = UIImage(data: data)?
            .downscaled(maxDimension: 1024)
            .jpegData(compressionQuality: 0.8)
        photoData = resized ?? data
    }

    // MARK: - Save

    private func save() {
        let target = pet ?? Pet(name: "", species: "")

        target.name = name.trimmed
        target.species = species.trimmed
        target.breed = breed.trimmed
        target.gender = gender
        target.dateOfBirth = dateOfBirth
        target.furColor = furColor.trimmed
        target.photoData = photoData

        target.microchipNumber = microchipNumber.nilIfBlank
        target.microchipLocation = target.microchipNumber == nil ? nil : microchipLocation.nilIfBlank
        target.microchipDate = target.microchipNumber != nil && hasMicrochipDate ? microchipDate : nil
        target.tattooNumber = tattooNumber.nilIfBlank
        target.tattooDate = target.tattooNumber != nil && hasTattooDate ? tattooDate : nil
        target.updatedAt = Date()

        if pet == nil {
            context.insert(target)
            target.addDefaultFoodTypes(in: context)
        }
        context.saveChanges()
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    PetFormView()
        .modelContainer(Persistence.preview)
}
