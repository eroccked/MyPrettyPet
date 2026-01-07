//
//  PetViewModel.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftUI
import Combine
import CloudKit

class PetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var pet: Pet?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // Медичні дані
    @Published var vaccinations: [Vaccination] = []
    @Published var dewormings: [Deworming] = []
    @Published var fleaTreatments: [FleaTreatment] = []
    
    // Годування
    @Published var feedingRecords: [FeedingRecord] = []
    @Published var foodTypes: [FoodType] = []
    
    // MARK: - Services
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(pet: Pet? = nil) {
        self.pet = pet
        if let pet = pet {
            loadPetData(for: pet)
        }
    }
    
    // MARK: - Load Pet Data
    func loadPetData(for pet: Pet) {
        self.pet = pet
        loadMedicalRecords()
        loadFeedingHistory()
        loadFoodTypes()
    }
    
    // MARK: - Save Pet
    func savePet(_ pet: Pet) {
        isLoading = true
        errorMessage = nil
        
        dataManager.savePet(pet) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let savedPet):
                    self?.pet = savedPet
                    print("✅ Pet saved successfully")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    print("❌ Error saving pet: \(error)")
                }
            }
        }
    }
    
    // MARK: - Delete Pet
    func deletePet() {
        guard let pet = pet else { return }
        
        isLoading = true
        errorMessage = nil
        
        dataManager.deletePet(pet) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.pet = nil
                    print("✅ Pet deleted successfully")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    print("❌ Error deleting pet: \(error)")
                }
            }
        }
    }
    
    // MARK: - Medical Records
    
    private func loadMedicalRecords() {
        guard let petID = pet?.id else { return }
        
        // Завантажити щеплення
        dataManager.medicalService.fetchVaccinations(for: petID) { [weak self] result in
            if case .success(let items) = result {
                DispatchQueue.main.async {
                    self?.vaccinations = items
                }
            }
        }
        
        // Завантажити глистування
        dataManager.medicalService.fetchDewormings(for: petID) { [weak self] result in
            if case .success(let items) = result {
                DispatchQueue.main.async {
                    self?.dewormings = items
                }
            }
        }
        
        // Завантажити обробки від бліх
        dataManager.medicalService.fetchFleaTreatments(for: petID) { [weak self] result in
            if case .success(let items) = result {
                DispatchQueue.main.async {
                    self?.fleaTreatments = items
                }
            }
        }
    }
    
    func addVaccination(_ vaccination: Vaccination) {
        dataManager.addVaccination(vaccination) { [weak self] result in
            if case .success(let newVaccination) = result {
                DispatchQueue.main.async {
                    self?.vaccinations.append(newVaccination)
                    self?.vaccinations.sort { $0.dateAdministered > $1.dateAdministered }
                }
            }
        }
    }
    
    func addDeworming(_ deworming: Deworming) {
        dataManager.addDeworming(deworming) { [weak self] result in
            if case .success(let newDeworming) = result {
                DispatchQueue.main.async {
                    self?.dewormings.append(newDeworming)
                    self?.dewormings.sort { $0.dateAdministered > $1.dateAdministered }
                }
            }
        }
    }
    
    func addFleaTreatment(_ fleaTreatment: FleaTreatment) {
        dataManager.addFleaTreatment(fleaTreatment) { [weak self] result in
            if case .success(let newTreatment) = result {
                DispatchQueue.main.async {
                    self?.fleaTreatments.append(newTreatment)
                    self?.fleaTreatments.sort { $0.dateAdministered > $1.dateAdministered }
                }
            }
        }
    }
    
    // MARK: - Feeding
    
    private func loadFeedingHistory() {
        guard let petID = pet?.id else { return }
        
        dataManager.fetchFeedingHistory(for: petID) { [weak self] result in
            if case .success(let records) = result {
                DispatchQueue.main.async {
                    self?.feedingRecords = records
                }
            }
        }
    }
    
    private func loadFoodTypes() {
        guard let petID = pet?.id else { return }
        
        dataManager.fetchActiveFoodTypes(for: petID) { [weak self] result in
            if case .success(let types) = result {
                DispatchQueue.main.async {
                    self?.foodTypes = types
                }
            }
        }
    }
    
    func addFeedingRecord(foodType: String, portion: String, notes: String? = nil) {
        guard let petID = pet?.id else { return }
        
        let userID = dataManager.cloudKitManager.userRecordID?.recordName ?? "unknown"
        let userName = dataManager.cloudKitManager.userName
        
        let record = FeedingRecord(
            petID: petID,
            foodType: foodType,
            portion: portion,
            notes: notes,
            fedBy: userID,
            fedByName: userName
        )
        
        dataManager.addFeedingRecord(record) { [weak self] result in
            if case .success(let newRecord) = result {
                DispatchQueue.main.async {
                    self?.feedingRecords.insert(newRecord, at: 0)
                }
            }
        }
    }
    
    func addFoodType(_ foodType: FoodType) {
        dataManager.addFoodType(foodType) { [weak self] result in
            if case .success(let newType) = result {
                DispatchQueue.main.async {
                    self?.foodTypes.append(newType)
                    self?.foodTypes.sort { $0.name < $1.name }
                }
            }
        }
    }
    
    // MARK: - Medical Reminders
    
    func checkUpcomingReminders() {
        guard let petID = pet?.id else { return }
        
        dataManager.fetchMedicalReminders(for: petID) { [weak self] result in
            if case .success(let reminders) = result {
                // Тут можна показати alert або badge з кількістю нагадувань
                print("📋 Medical reminders: \(reminders.totalCount)")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var petAge: String {
        guard let pet = pet else { return "" }
        let age = Calendar.current.dateComponents([.year, .month], from: pet.dateOfBirth, to: Date())
        
        if let years = age.year, years > 0 {
            if let months = age.month, months > 0 {
                return "\(years) р. \(months) міс."
            }
            return "\(years) р."
        } else if let months = age.month, months > 0 {
            return "\(months) міс."
        }
        return "Новонароджений"
    }
    
    var lastFeeding: FeedingRecord? {
        return feedingRecords.first
    }
    
    var todayFeedingCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return feedingRecords.filter { Calendar.current.isDate($0.dateTime, inSameDayAs: today) }.count
    }
}
