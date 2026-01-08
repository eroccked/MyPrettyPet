//
//  AddPetViewModel.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import Foundation
import SwiftUI
import Combine
import CloudKit 

class AddPetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedImage: UIImage?
    @Published var name: String = ""
    @Published var species: String = ""
    @Published var breed: String = ""
    @Published var gender: Pet.Gender = .unknown
    @Published var dateOfBirth: Date = Date()
    @Published var furColor: String = ""
    
    @Published var microchipNumber: String = ""
    @Published var microchipDate: Date?
    @Published var microchipLocation: String = ""
    @Published var tattooNumber: String = ""
    @Published var tattooDate: Date?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Services
    private let dataManager = DataManager.shared
    
    // MARK: - Computed Properties
    var isValid: Bool {
        return !name.isEmpty &&
               !species.isEmpty &&
               !breed.isEmpty &&
               !furColor.isEmpty
    }
    
    // MARK: - Save Pet
    func savePet(completion: @escaping () -> Void) {
        guard isValid else { return }
        guard let ownerID = dataManager.cloudKitManager.userRecordID?.recordName ?? "local-user" as String? else {
            errorMessage = "Не вдалося визначити користувача"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Конвертуємо фото в Data
        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // Створюємо Pet
        let pet = Pet(
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            dateOfBirth: dateOfBirth,
            photoData: photoData,
            furColor: furColor,
            microchipNumber: microchipNumber.isEmpty ? nil : microchipNumber,
            microchipDate: microchipDate,
            microchipLocation: microchipLocation.isEmpty ? nil : microchipLocation,
            tattooNumber: tattooNumber.isEmpty ? nil : tattooNumber,
            tattooDate: tattooDate,
            ownerID: ownerID
        )
        
        // Зберігаємо
        dataManager.savePet(pet) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    print("✅ Pet saved successfully")
                    completion()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    print("❌ Error saving pet: \(error)")
                }
            }
        }
    }
}
