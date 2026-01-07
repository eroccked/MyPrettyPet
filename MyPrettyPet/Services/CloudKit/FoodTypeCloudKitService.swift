//
//  FoodTypeCloudKitService.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

class FoodTypeCloudKitService {
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    
    init() {
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Create/Update Food Type
    func saveFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        let record = foodType.toCKRecord()
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let savedRecord = savedRecord,
                  let updatedFoodType = FoodType.fromCKRecord(savedRecord) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.conversionFailed))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(updatedFoodType))
            }
        }
    }
    
    // MARK: - Fetch All Food Types for Pet
    func fetchFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@", petID.uuidString)
        let query = CKQuery(recordType: "FoodType", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let records = records else {
                DispatchQueue.main.async {
                    completion(.success([]))
                }
                return
            }
            
            let foodTypes = records.compactMap { FoodType.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(foodTypes))
            }
        }
    }
    
    // MARK: - Fetch Active Food Types
    func fetchActiveFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@ AND isActive == 1", petID.uuidString)
        let query = CKQuery(recordType: "FoodType", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let records = records else {
                DispatchQueue.main.async {
                    completion(.success([]))
                }
                return
            }
            
            let foodTypes = records.compactMap { FoodType.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(foodTypes))
            }
        }
    }
    
    // MARK: - Fetch Food Types by Category
    func fetchFoodTypes(for petID: UUID, category: FoodType.FoodCategory, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@ AND category == %@ AND isActive == 1",
                                   petID.uuidString,
                                   category.rawValue)
        let query = CKQuery(recordType: "FoodType", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let records = records else {
                DispatchQueue.main.async {
                    completion(.success([]))
                }
                return
            }
            
            let foodTypes = records.compactMap { FoodType.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(foodTypes))
            }
        }
    }
    
    // MARK: - Archive Food Type (Soft Delete)
    func archiveFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        var archivedFoodType = foodType
        archivedFoodType.isActive = false
        archivedFoodType.updatedAt = Date()
        
        saveFoodType(archivedFoodType, completion: completion)
    }
    
    // MARK: - Restore Food Type
    func restoreFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        var restoredFoodType = foodType
        restoredFoodType.isActive = true
        restoredFoodType.updatedAt = Date()
        
        saveFoodType(restoredFoodType, completion: completion)
    }
    
    // MARK: - Delete Food Type (Hard Delete)
    func deleteFoodType(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        privateDatabase.delete(withRecordID: recordID) { deletedRecordID, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Create Default Food Types
    func createDefaultFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        let defaultFoods = [
            FoodType(petID: petID, name: "Сухий корм (основний)", category: .dryFood),
            FoodType(petID: petID, name: "Вологий корм", category: .wetFood),
            FoodType(petID: petID, name: "Курка", category: .natural),
            FoodType(petID: petID, name: "Яловичина", category: .natural),
            FoodType(petID: petID, name: "Риба", category: .natural),
            FoodType(petID: petID, name: "Ласощі", category: .treats),
        ]
        
        let group = DispatchGroup()
        var savedFoodTypes: [FoodType] = []
        var saveError: Error?
        
        for food in defaultFoods {
            group.enter()
            saveFoodType(food) { result in
                switch result {
                case .success(let savedFood):
                    savedFoodTypes.append(savedFood)
                case .failure(let error):
                    saveError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = saveError {
                completion(.failure(error))
            } else {
                completion(.success(savedFoodTypes))
            }
        }
    }
    
    // MARK: - Check if Food Type Name Exists
    func checkFoodTypeExists(name: String, for petID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@ AND name == %@", petID.uuidString, name)
        let query = CKQuery(recordType: "FoodType", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let exists = (records?.count ?? 0) > 0
            
            DispatchQueue.main.async {
                completion(.success(exists))
            }
        }
    }
}
