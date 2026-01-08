//
//  PetCloudKitService.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

class PetCloudKitService {
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    
    init() {
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Create/Update Pet
    func savePet(_ pet: Pet, completion: @escaping (Result<Pet, Error>) -> Void) {
        let record = pet.toCKRecord()
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let savedRecord = savedRecord,
                  var updatedPet = Pet.fromCKRecord(savedRecord) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.conversionFailed))
                }
                return
            }
            
            // Зберігаємо всі зв'язки
            updatedPet.vaccinationIDs = pet.vaccinationIDs
            updatedPet.dewormingIDs = pet.dewormingIDs
            updatedPet.fleaTreatmentIDs = pet.fleaTreatmentIDs
            updatedPet.feedingRecordIDs = pet.feedingRecordIDs
            
            DispatchQueue.main.async {
                completion(.success(updatedPet))
            }
        }
    }
    
    // MARK: - Fetch Pet by ID
    func fetchPet(recordID: CKRecord.ID, completion: @escaping (Result<Pet, Error>) -> Void) {
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let record = record,
                  let pet = Pet.fromCKRecord(record) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.recordNotFound))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(pet))
            }
        }
    }
    
    // MARK: - Fetch All User Pets
    func fetchAllPets(completion: @escaping (Result<[Pet], Error>) -> Void) {
        guard let ownerID = CloudKitManager.shared.userRecordID?.recordName else {
            completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
            return
        }
        
        let predicate = NSPredicate(format: "ownerID == %@", ownerID)
        let query = CKQuery(recordType: "Pet", predicate: predicate)
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
            
            let pets = records.compactMap { Pet.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(pets))
            }
        }
    }
    
    // MARK: - Delete Pet
    func deletePet(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    // MARK: - Share Pet (CKShare)
    func sharePet(_ pet: Pet, completion: @escaping (Result<CKShare, Error>) -> Void) {
        guard let recordID = pet.recordID else {
            completion(.failure(CloudKitManager.CloudKitError.recordNotFound))
            return
        }
        
        // Отримуємо запис
        privateDatabase.fetch(withRecordID: recordID) { [weak self] record, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.recordNotFound))
                }
                return
            }
            
            // Створюємо share
            let share = CKShare(rootRecord: record)
            share[CKShare.SystemFieldKey.title] = "Паспорт \(pet.name)" as CKRecordValue
            share.publicPermission = .none // Тільки запрошені користувачі
            
            // Налаштування прав для учасників
            share[CKShare.SystemFieldKey.shareType] = "Pet Passport" as CKRecordValue
            
            // Зберігаємо і record і share разом
            let operation = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(share))
                }
            }
            
            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInitiated
            
            self?.privateDatabase.add(operation)
        }
    }
    
    // MARK: - Check User Role
    func checkUserRole(for pet: Pet, completion: @escaping (Result<UserRole, Error>) -> Void) {
        guard let recordID = pet.recordID else {
            completion(.failure(CloudKitManager.CloudKitError.recordNotFound))
            return
        }
        
        guard let currentUserID = CloudKitManager.shared.userRecordID?.recordName else {
            completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
            return
        }
        
        // Перевіряємо чи користувач є власником
        if pet.ownerID == currentUserID {
            completion(.success(.owner))
            return
        }
        
        // Перевіряємо share
        let fetchSharesOperation = CKFetchShareMetadataOperation(shareURLs: [])
        // Тут потрібна додаткова логіка для перевірки share
        // Поки що повертаємо participant
        completion(.success(.participant))
    }
    
    enum UserRole {
        case owner
        case participant
    }
}
