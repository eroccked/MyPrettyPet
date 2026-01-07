//
//  PetListViewModel.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftUI
import Combine

class PetListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var pets: [Pet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isSignedInToiCloud: Bool = false
    
    // MARK: - Services
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        setupBindings()
        loadPets()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Підписуємося на зміни в DataManager
        dataManager.$pets
            .sink { [weak self] pets in
                self?.pets = pets
            }
            .store(in: &cancellables)
        
        dataManager.$isLoading
            .sink { [weak self] loading in
                self?.isLoading = loading
            }
            .store(in: &cancellables)
        
        dataManager.$errorMessage
            .sink { [weak self] message in
                self?.errorMessage = message
                self?.showError = message != nil
            }
            .store(in: &cancellables)
        
        dataManager.cloudKitManager.$isSignedInToiCloud
            .sink { [weak self] signedIn in
                self?.isSignedInToiCloud = signedIn
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Pets
    func loadPets() {
        dataManager.loadPets()
    }
    
    // MARK: - Add Pet
    func addPet(_ pet: Pet) {
        isLoading = true
        
        dataManager.savePet(pet) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let savedPet):
                    // Створити дефолтні типи їжі для нової тварини
                    self?.createDefaultFoodTypes(for: savedPet)
                    print("✅ Pet added successfully")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    print("❌ Error adding pet: \(error)")
                }
            }
        }
    }
    
    // MARK: - Delete Pet
    func deletePet(_ pet: Pet) {
        dataManager.deletePet(pet) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }
    
    // MARK: - Create Default Food Types
    private func createDefaultFoodTypes(for pet: Pet) {
        dataManager.createDefaultFoodTypes(for: pet.id) { result in
            if case .success = result {
                print("✅ Default food types created")
            }
        }
    }
    
    // MARK: - Refresh
    func refresh() {
        loadPets()
    }
    
    // MARK: - iCloud Check
    func checkiCloudStatus() {
        dataManager.checkiCloudStatus()
    }
}
