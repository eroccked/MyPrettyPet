//
//  FeedingCloudKitService.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

class FeedingCloudKitService {
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    
    init() {
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Create Feeding Record
    func saveFeedingRecord(_ record: FeedingRecord, completion: @escaping (Result<FeedingRecord, Error>) -> Void) {
        let ckRecord = record.toCKRecord()
        
        privateDatabase.save(ckRecord) { savedRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let savedRecord = savedRecord,
                  let updatedRecord = FeedingRecord.fromCKRecord(savedRecord) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.conversionFailed))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(updatedRecord))
            }
        }
    }
    
    // MARK: - Fetch Feeding Records for Pet
    func fetchFeedingRecords(for petID: UUID, completion: @escaping (Result<[FeedingRecord], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@", petID.uuidString)
        let query = CKQuery(recordType: "FeedingRecord", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: false)]
        
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
            
            let feedingRecords = records.compactMap { FeedingRecord.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(feedingRecords))
            }
        }
    }
    
    // MARK: - Fetch Recent Feeding Records (Last 24 hours)
    func fetchRecentFeedingRecords(for petID: UUID, completion: @escaping (Result<[FeedingRecord], Error>) -> Void) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        let predicate = NSPredicate(format: "petID == %@ AND dateTime >= %@", petID.uuidString, yesterday as NSDate)
        let query = CKQuery(recordType: "FeedingRecord", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: false)]
        
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
            
            let feedingRecords = records.compactMap { FeedingRecord.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(feedingRecords))
            }
        }
    }
    
    // MARK: - Delete Feeding Record
    func deleteFeedingRecord(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
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
}
