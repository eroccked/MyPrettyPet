//
//  FeedingRecord.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

struct FeedingRecord: Identifiable {
    var id: UUID
    var recordID: CKRecord.ID?
    
    var petID: UUID
    var foodType: String
    var portion: String
    var dateTime: Date
    var notes: String?
    var fedBy: String
    var fedByName: String?
    
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        petID: UUID,
        foodType: String,
        portion: String,
        dateTime: Date = Date(),
        notes: String? = nil,
        fedBy: String,
        fedByName: String? = nil
    ) {
        self.id = id
        self.petID = petID
        self.foodType = foodType
        self.portion = portion
        self.dateTime = dateTime
        self.notes = notes
        self.fedBy = fedBy
        self.fedByName = fedByName
        self.createdAt = Date()
    }
}

// MARK: - Codable
extension FeedingRecord: Codable {
    enum CodingKeys: String, CodingKey {
        case id, petID, foodType, portion, dateTime
        case notes, fedBy, fedByName, createdAt
    }
}

// MARK: - CloudKit Extension
extension FeedingRecord {
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: "FeedingRecord", recordID: recordID)
        } else {
            record = CKRecord(recordType: "FeedingRecord")
        }
        
        record["id"] = id.uuidString
        record["petID"] = petID.uuidString
        record["foodType"] = foodType
        record["portion"] = portion
        record["dateTime"] = dateTime
        record["notes"] = notes
        record["fedBy"] = fedBy
        record["fedByName"] = fedByName
        record["createdAt"] = createdAt
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> FeedingRecord? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let petIDString = record["petID"] as? String,
            let petID = UUID(uuidString: petIDString),
            let foodType = record["foodType"] as? String,
            let portion = record["portion"] as? String,
            let dateTime = record["dateTime"] as? Date,
            let fedBy = record["fedBy"] as? String,
            let createdAt = record["createdAt"] as? Date
        else { return nil }
        
        var feedingRecord = FeedingRecord(
            id: id,
            petID: petID,
            foodType: foodType,
            portion: portion,
            dateTime: dateTime,
            notes: record["notes"] as? String,
            fedBy: fedBy,
            fedByName: record["fedByName"] as? String
        )
        
        feedingRecord.recordID = record.recordID
        feedingRecord.createdAt = createdAt
        
        return feedingRecord
    }
}
