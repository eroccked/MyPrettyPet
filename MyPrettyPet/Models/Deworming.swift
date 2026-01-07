//
//  Deworming.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

struct Deworming: Identifiable {
    var id: UUID
    var recordID: CKRecord.ID?
    
    var petID: UUID
    var medicationName: String
    var dateAdministered: Date
    var nextDueDate: Date?
    var dosage: String?
    var notes: String?

    var createdAt: Date
    var updatedAt: Date
    var createdBy: String
    
    init(
        id: UUID = UUID(),
        petID: UUID,
        medicationName: String,
        dateAdministered: Date,
        nextDueDate: Date? = nil,
        dosage: String? = nil,
        notes: String? = nil,
        createdBy: String
    ) {
        self.id = id
        self.petID = petID
        self.medicationName = medicationName
        self.dateAdministered = dateAdministered
        self.nextDueDate = nextDueDate
        self.dosage = dosage
        self.notes = notes
        self.createdBy = createdBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var needsReminder: Bool {
        guard let nextDueDate = nextDueDate else { return false }
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0
        return daysUntilDue <= 14 && daysUntilDue >= 0
    }
}

// MARK: - Codable
extension Deworming: Codable {
    enum CodingKeys: String, CodingKey {
        case id, petID, medicationName, dateAdministered, nextDueDate
        case dosage, notes, createdAt, updatedAt, createdBy
    }
}

// MARK: - CloudKit Extension
extension Deworming {
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: "Deworming", recordID: recordID)
        } else {
            record = CKRecord(recordType: "Deworming")
        }
        
        record["id"] = id.uuidString
        record["petID"] = petID.uuidString
        record["medicationName"] = medicationName
        record["dateAdministered"] = dateAdministered
        record["nextDueDate"] = nextDueDate
        record["dosage"] = dosage
        record["notes"] = notes
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["createdBy"] = createdBy
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> Deworming? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let petIDString = record["petID"] as? String,
            let petID = UUID(uuidString: petIDString),
            let medicationName = record["medicationName"] as? String,
            let dateAdministered = record["dateAdministered"] as? Date,
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date,
            let createdBy = record["createdBy"] as? String
        else { return nil }
        
        var deworming = Deworming(
            id: id,
            petID: petID,
            medicationName: medicationName,
            dateAdministered: dateAdministered,
            nextDueDate: record["nextDueDate"] as? Date,
            dosage: record["dosage"] as? String,
            notes: record["notes"] as? String,
            createdBy: createdBy
        )
        
        deworming.recordID = record.recordID
        deworming.createdAt = createdAt
        deworming.updatedAt = updatedAt
        
        return deworming
    }
}
