//
//  FoodTypeCloudKitService.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//


import Foundation
import CloudKit

class FoodTypeCloudKitService {
    
    private var container: CKContainer?
    private var privateDatabase: CKDatabase?
    
    init() {
        // Поки CloudKit не налаштований
    }
    
    func saveFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
    }
    
    func fetchFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        completion(.success([]))
    }
    
    func fetchActiveFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        completion(.success([]))
    }
    
    func fetchFoodTypes(for petID: UUID, category: FoodType.FoodCategory, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        completion(.success([]))
    }
    
    func archiveFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
    }
    
    func restoreFoodType(_ foodType: FoodType, completion: @escaping (Result<FoodType, Error>) -> Void) {
        completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
    }
    
    func deleteFoodType(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
    }
    
    func createDefaultFoodTypes(for petID: UUID, completion: @escaping (Result<[FoodType], Error>) -> Void) {
        completion(.success([]))
    }
    
    func checkFoodTypeExists(name: String, for petID: UUID, completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(false))
    }
}
