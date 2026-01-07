//
//  DataManager.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit
import Combine

class DataManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DataManager()
    
    // MARK: - Services
    let cloudKitManager = CloudKitManager.shared
    let petService = PetCloudKitService()
    let feedingService = FeedingCloudKitService()
    let medicalService = MedicalCloudKitService()
    let foodTypeService = FoodTypeCloudKitService()
    
    // MARK: - Published Properties
    @Published var pets: [Pet] = []
    @Published var currentPet: Pet?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    private init() {
        cloudKitManager.$isSignedInToiCloud
            .sink { [weak self] isSignedIn in
                if isSignedIn {
                    self?.loadPets()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Pet Operations
    
    func loadPets() {
        isLoading = true
        errorMessage = nil
        
        petService.fetchAllPets { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let pets):
                    self?.pets = pets
                    print("✅ Loaded \(pets.count) pets")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error loading pets: \(error)")
                }
            }
        }
    }
    
    func savePet(_ pet: Pet, completion: @escaping (Result<Pet, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        petService.savePet(pet) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let savedPet):
                    if let index = self?.pets.firstIndex(where: { $0.id == savedPet.id }) {
                        self?.pets[index] = savedPet
                    } else {
                        self?.pets.append(savedPet)
                    }
                    print("✅ Pet saved: \(savedPet.name)")
                    completion(.success(savedPet))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error saving pet: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deletePet(_ pet: Pet, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let recordID = pet.recordID else {
            completion(.failure(CloudKitManager.CloudKitError.recordNotFound))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        petService.deletePet(recordID: recordID) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.pets.removeAll { $0.id == pet.id }
                    print("✅ Pet deleted: \(pet.name)")
                    completion(.success(()))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error deleting pet: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Feeding Operations
    
    func addFeedingRecord(_ record: FeedingRecord, completion: @escaping (Result<FeedingRecord, Error>) -> Void) {
        feedingService.saveFeedingRecord(record, completion: completion)
    }
    
    func fetchFeedingHistory(for petID: UUID, completion: @escaping (Result<[FeedingRecord], Error>) -> Void) {
        feedingService.fetchFeedingRecords(for: petID, completion: completion)
    }
    
    func fetchRecentFeeding(for petID: UUID, completion: @escaping (Result<[FeedingRecord], Error>) -> Void) {
        feedingService.fetchRecentFeedingRecords(for: petID, completion: completion)
    }
    
    // MARK: - Medical Operations
    
    func addVaccination(_ vaccination: Vaccination, completion: @escaping (Result<Vaccination, Error>) -> Void) {
        medicalService.saveVaccination(vaccination, completion: completion)
    }
    
    func addDeworming(_ deworming: Deworming, completion: @escaping (Result<Deworming, Error>) -> Void) {
        medicalService.saveDeworming(deworming, completion: completion)
    }
    
    func addFleaTreatment(_ fleaTreatment: FleaTreatment, completion: @escaping (Result<FleaTreatment, Error>) -> Void) {
        medicalService.saveFleaTreatment(fleaTreatment, completion: completion)
    }
    
    func fetchMedicalReminders(for petID: UUID, completion: @escaping (Result<MedicalCloudKitService.MedicalReminders, Error>) -> Void) {
        medicalService.fetchAllUpcomingMedicalRecords(for: petID, completion: completion)
    }
    
    // MARK: - Food Type Operations
    
    func fetchActiveFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        foodTypeService.fetchActiveFoodTypes(for: petID, completion: completion)
    }
    
    func addFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        foodTypeService.saveFoodType(foodType, completion: completion)
    }
    
    func createDefaultFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        foodTypeService.createDefaultFoodTypes(for: petID, completion: completion)
    }
    
    // MARK: - Sharing Operations
    
    func sharePet(_ pet: Pet, completion: @escaping (Result<CKShare, Error>) -> Void) {
        petService.sharePet(pet, completion: completion)
    }
    
    func checkUserRole(for pet: Pet, completion: @escaping (Result<PetCloudKitService.UserRole, Error>) -> Void) {
        petService.checkUserRole(for: pet, completion: completion)
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func checkiCloudStatus() {
        cloudKitManager.checkiCloudStatus()
    }
}
