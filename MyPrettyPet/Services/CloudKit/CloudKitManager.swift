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
    private var container: CKContainer?
    private var privateDatabase: CKDatabase?
    private var sharedDatabase: CKDatabase?
    
    @Published var isSignedInToiCloud: Bool = false
    @Published var userRecordID: CKRecord.ID?
    @Published var userName: String?
    @Published var isCloudKitAvailable: Bool = false
    
    // MARK: - Init
    private init() {
        // НЕ викликаємо setupCloudKit() тут!
        // Він викличеться коли треба
    }
    
    private func setupCloudKit() {
        guard container == nil else { return } // Вже налаштовано
        
        // Просто створюємо контейнер
        self.container = CKContainer.default()
        self.privateDatabase = container?.privateCloudDatabase
        self.sharedDatabase = container?.sharedCloudDatabase
        self.isCloudKitAvailable = true
        
        checkiCloudStatus()
    }
    
    // MARK: - iCloud Status
    func checkiCloudStatus() {
        // Спробуємо налаштувати CloudKit при першому виклику
        if container == nil {
            setupCloudKit()
        }
        
        guard let container = container else {
            print("⚠️ CloudKit not configured")
            DispatchQueue.main.async {
                self.isSignedInToiCloud = false
                self.isCloudKitAvailable = false
            }
            return
        }
        
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
        guard let container = container else { return }
        
        container.fetchUserRecordID { [weak self] recordID, error in
            if let error = error {
                print("❌ Error fetching user record ID: \(error)")
                return
            }
            
            guard let recordID = recordID else { return }
            
            DispatchQueue.main.async {
                self?.userRecordID = recordID
            }
            
            container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
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
        guard isCloudKitAvailable else {
            completion(.failure(CloudKitError.iCloudAccountNotAvailable))
            return
        }
    }
    
    func fetch<T>(recordID: CKRecord.ID, completion: @escaping (Result<T, Error>) -> Void) {
        guard isCloudKitAvailable, let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.iCloudAccountNotAvailable))
            return
        }
        
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
        guard isCloudKitAvailable, let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.iCloudAccountNotAvailable))
            return
        }
        
        privateDatabase.delete(withRecordID: recordID) { deletedRecordID, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func query<T>(recordType: String, predicate: NSPredicate = NSPredicate(value: true), sortDescriptors: [NSSortDescriptor] = [], completion: @escaping (Result<[T], Error>) -> Void) {
        guard isCloudKitAvailable, let privateDatabase = privateDatabase else {
            completion(.failure(CloudKitError.iCloudAccountNotAvailable))
            return
        }
        
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
