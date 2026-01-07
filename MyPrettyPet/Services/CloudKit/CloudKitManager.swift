//
//  CloudKitManager.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit
import Combine

class CloudKitManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = CloudKitManager()
    
    // MARK: - Properties
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase
    
    @Published var isSignedInToiCloud: Bool = false
    @Published var userRecordID: CKRecord.ID?
    @Published var userName: String?
    
    // MARK: - Init
    private init() {
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase
        
        checkiCloudStatus()
    }
    
    // MARK: - iCloud Status
    func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isSignedInToiCloud = true
                    self?.fetchUserIdentity()
                case .noAccount:
                    print("⚠️ No iCloud account")
                    self?.isSignedInToiCloud = false
                case .restricted:
                    print("⚠️ iCloud restricted")
                    self?.isSignedInToiCloud = false
                case .couldNotDetermine:
                    print("⚠️ Could not determine iCloud status")
                    self?.isSignedInToiCloud = false
                case .temporarilyUnavailable:
                    print("⚠️ iCloud temporarily unavailable")
                    self?.isSignedInToiCloud = false
                @unknown default:
                    print("⚠️ Unknown iCloud status")
                    self?.isSignedInToiCloud = false
                }
            }
        }
    }
    
    // MARK: - Fetch User Identity
    private func fetchUserIdentity() {
        container.fetchUserRecordID { [weak self] recordID, error in
            if let error = error {
                print("❌ Error fetching user record ID: \(error)")
                return
            }
            
            guard let recordID = recordID else { return }
            
            DispatchQueue.main.async {
                self?.userRecordID = recordID
            }
            
            self?.container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
                if let error = error {
                    print("❌ Error discovering user identity: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.userName = identity?.nameComponents?.givenName
                    print("✅ User logged in: \(self?.userName ?? "Unknown")")
                }
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func save<T>(_ item: T, completion: @escaping (Result<T, Error>) -> Void) where T: AnyObject {
        
    }
    
    func fetch<T>(recordID: CKRecord.ID, completion: @escaping (Result<T, Error>) -> Void) {
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let record = record else {
                completion(.failure(NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No record found"])))
                return
            }
            
        }
    }
    
    func delete(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        privateDatabase.delete(withRecordID: recordID) { deletedRecordID, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func query<T>(recordType: String, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor] = [], completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let records = records else {
                completion(.success([]))
                return
            }
            
        }
    }
}

// MARK: - Error Handling
extension CloudKitManager {
    enum CloudKitError: LocalizedError {
        case iCloudAccountNotAvailable
        case recordNotFound
        case conversionFailed
        case permissionDenied
        case networkUnavailable
        
        var errorDescription: String? {
            switch self {
            case .iCloudAccountNotAvailable:
                return "iCloud акаунт недоступний. Увійдіть в iCloud в налаштуваннях."
            case .recordNotFound:
                return "Запис не знайдено."
            case .conversionFailed:
                return "Помилка конвертації даних."
            case .permissionDenied:
                return "Доступ заборонено."
            case .networkUnavailable:
                return "Мережа недоступна. Перевірте інтернет з'єднання."
            }
        }
    }
}
