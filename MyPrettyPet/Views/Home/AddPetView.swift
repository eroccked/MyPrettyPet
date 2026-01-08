//
//  AddPetView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import PhotosUI

struct AddPetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddPetViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        // Фото
                        PhotoSection(selectedImage: $viewModel.selectedImage)
                        
                        // Основна інформація
                        BasicInfoSection(
                            name: $viewModel.name,
                            species: $viewModel.species,
                            breed: $viewModel.breed,
                            gender: $viewModel.gender,
                            dateOfBirth: $viewModel.dateOfBirth,
                            furColor: $viewModel.furColor
                        )
                        
                        // Ідентифікація
                        IdentificationSection(
                            microchipNumber: $viewModel.microchipNumber,
                            microchipDate: $viewModel.microchipDate,
                            microchipLocation: $viewModel.microchipLocation,
                            tattooNumber: $viewModel.tattooNumber,
                            tattooDate: $viewModel.tattooDate
                        )
                        
                        // Кнопка зберегти
                        Button(action: {
                            viewModel.savePet {
                                dismiss()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Зберегти")
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                        .opacity(viewModel.isValid ? 1.0 : 0.5)
                        .padding(.horizontal, Theme.Spacing.medium)
                        .padding(.bottom, Theme.Spacing.extraLarge)
                    }
                    .padding(.top, Theme.Spacing.medium)
                }
            }
            .navigationTitle("Нова тварина")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .alert("Помилка", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Невідома помилка")
            }
        }
    }
}

// MARK: - Photo Section
struct PhotoSection: View {
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Button(action: { showImagePicker = true }) {
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Theme.Colors.accent.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 30))
                                    Text("Додати фото")
                                        .font(Theme.Fonts.caption)
                                }
                                .foregroundColor(Theme.Colors.accent)
                            )
                    }
                }
            }
            
            if selectedImage != nil {
                Button("Змінити фото") {
                    showImagePicker = true
                }
                .font(Theme.Fonts.callout)
                .foregroundColor(Theme.Colors.accent)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

// MARK: - Basic Info Section
struct BasicInfoSection: View {
    @Binding var name: String
    @Binding var species: String
    @Binding var breed: String
    @Binding var gender: Pet.Gender
    @Binding var dateOfBirth: Date
    @Binding var furColor: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Text("Основна інформація")
                .font(Theme.Fonts.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.medium)
            
            VStack(spacing: Theme.Spacing.medium) {
                CustomTextField(
                    title: "Ім'я",
                    text: $name,
                    placeholder: "Мурчик"
                )
                
                CustomTextField(
                    title: "Вид",
                    text: $species,
                    placeholder: "Кіт, Собака, Папуга..."
                )
                
                CustomTextField(
                    title: "Порода",
                    text: $breed,
                    placeholder: "Британець"
                )
                
                // Стать
                VStack(alignment: .leading, spacing: 8) {
                    Text("Стать")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.secondary)
                    
                    HStack(spacing: Theme.Spacing.small) {
                        ForEach(Pet.Gender.allCases, id: \.self) { genderOption in
                            Button(action: {
                                gender = genderOption
                            }) {
                                Text(genderOption.rawValue)
                                    .font(Theme.Fonts.callout)
                                    .foregroundColor(gender == genderOption ? .white : Theme.Colors.primary)
                                    .padding(.horizontal, Theme.Spacing.medium)
                                    .padding(.vertical, Theme.Spacing.small)
                                    .background(gender == genderOption ? Theme.Colors.accent : Theme.Colors.cardBackground)
                                    .cornerRadius(Theme.CornerRadius.medium)
                                    .shadow(
                                        color: gender == genderOption ? Color.clear : Theme.Shadow.small.color,
                                        radius: Theme.Shadow.small.radius
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.medium)
                
                // Дата народження
                VStack(alignment: .leading, spacing: 8) {
                    Text("Дата народження")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.secondary)
                    
                    DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                .padding(.horizontal, Theme.Spacing.medium)
                
                CustomTextField(
                    title: "Колір шерсті",
                    text: $furColor,
                    placeholder: "Сірий"
                )
            }
            .padding(.vertical, Theme.Spacing.small)
            .cardStyle()
            .padding(.horizontal, Theme.Spacing.medium)
        }
    }
}

// MARK: - Identification Section
struct IdentificationSection: View {
    @Binding var microchipNumber: String
    @Binding var microchipDate: Date?
    @Binding var microchipLocation: String
    @Binding var tattooNumber: String
    @Binding var tattooDate: Date?
    
    @State private var showMicrochipDate = false
    @State private var showTattooDate = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Text("Ідентифікація (опціонально)")
                .font(Theme.Fonts.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Spacing.medium)
            
            VStack(spacing: Theme.Spacing.medium) {
                CustomTextField(
                    title: "Номер мікрочіпа",
                    text: $microchipNumber,
                    placeholder: "123456789"
                )
                
                if !microchipNumber.isEmpty {
                    Toggle("Вказати дату мікрочіпування", isOn: $showMicrochipDate)
                        .padding(.horizontal, Theme.Spacing.medium)
                    
                    if showMicrochipDate {
                        DatePicker("Дата мікрочіпування",
                                 selection: Binding(
                                    get: { microchipDate ?? Date() },
                                    set: { microchipDate = $0 }
                                 ),
                                 displayedComponents: .date)
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    CustomTextField(
                        title: "Місцезнаходження мікрочіпу",
                        text: $microchipLocation,
                        placeholder: "Ліва лопатка"
                    )
                }
                
                Divider()
                    .padding(.vertical, Theme.Spacing.small)
                
                CustomTextField(
                    title: "Номер тату",
                    text: $tattooNumber,
                    placeholder: "ABC123"
                )
                
                if !tattooNumber.isEmpty {
                    Toggle("Вказати дату тату", isOn: $showTattooDate)
                        .padding(.horizontal, Theme.Spacing.medium)
                    
                    if showTattooDate {
                        DatePicker("Дата тату",
                                 selection: Binding(
                                    get: { tattooDate ?? Date() },
                                    set: { tattooDate = $0 }
                                 ),
                                 displayedComponents: .date)
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.small)
            .cardStyle()
            .padding(.horizontal, Theme.Spacing.medium)
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.secondary)
            
            TextField(placeholder, text: $text)
                .font(Theme.Fonts.body)
                .padding(Theme.Spacing.small)
                .background(Theme.Colors.background)
                .cornerRadius(Theme.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Theme.Colors.secondary.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, Theme.Spacing.medium)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
struct AddPetView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetView()
    }
}
