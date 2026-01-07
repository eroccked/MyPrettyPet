//
//  FeedingCloudKitService.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//


import Foundation
import CloudKit

class FeedingCloudKitService {
    
    private var container: CKContainer?
    private var privateDatabase: CKDatabase?
    
    init() {
        // Поки CloudKit не налаштований
    }
    
    func saveFeedingRecord(_ record: FeedingRecord, completion: @escaping (Result<FeedingRecord, Error>) -> Void) {
        completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
    }
    
    func fetchFeedingRecords(for petID: UUID, completion: @escaping (Result<[FeedingRecord], Error>) -> Void) {
        completion(.success([]))
    }
    
    func fetchRecentFeedingRecords(for petID: UUID, completion: @escaping (Result<[FeedingRecord], Error>) -> Void) {
        completion(.success([]))
    }
    
    func deleteFeedingRecord(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.failure(CloudKitManager.CloudKitError.iCloudAccountNotAvailable))
    }
}
