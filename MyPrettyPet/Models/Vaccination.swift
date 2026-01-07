//
//  Vaccination.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

struct Vaccination: Identifiable {
    var id: UUID
    var recordID: CKRecord.ID?
    
    var petID: UUID
    var vaccineName: String
    var dateAdministered: Date
    var nextDueDate: Date?
    var veterinaryClinic: String?
    var serialNumber: String?
    var notes: String?
    
    var createdAt: Date
    var updatedAt: Date
    var createdBy: String
    
    init(
        id: UUID = UUID(),
        petID: UUID,
        vaccineName: String,
        dateAdministered: Date,
        nextDueDate: Date? = nil,
        veterinaryClinic: String? = nil,
        serialNumber: String? = nil,
        notes: String? = nil,
        createdBy: String
    ) {
        self.id = id
        self.petID = petID
        self.vaccineName = vaccineName
        self.dateAdministered = dateAdministered
        self.nextDueDate = nextDueDate
        self.veterinaryClinic = veterinaryClinic
        self.serialNumber = serialNumber
        self.notes = notes
        self.createdBy = createdBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var needsReminder: Bool {
        guard let nextDueDate = nextDueDate else { return false }
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0
        return daysUntilDue <= 30 && daysUntilDue >= 0
    }
}

// MARK: - Codable
extension Vaccination: Codable {
    enum CodingKeys: String, CodingKey {
        case id, petID, vaccineName, dateAdministered, nextDueDate
        case veterinaryClinic, serialNumber, notes, createdAt, updatedAt, createdBy
    }
}

// MARK: - CloudKit Extension
extension Vaccination {
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: "Vaccination", recordID: recordID)
        } else {
            record = CKRecord(recordType: "Vaccination")
        }
        
        record["id"] = id.uuidString
        record["petID"] = petID.uuidString
        record["vaccineName"] = vaccineName
        record["dateAdministered"] = dateAdministered
        record["nextDueDate"] = nextDueDate
        record["veterinaryClinic"] = veterinaryClinic
        record["serialNumber"] = serialNumber
        record["notes"] = notes
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["createdBy"] = createdBy
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> Vaccination? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let petIDString = record["petID"] as? String,
            let petID = UUID(uuidString: petIDString),
            let vaccineName = record["vaccineName"] as? String,
            let dateAdministered = record["dateAdministered"] as? Date,
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date,
            let createdBy = record["createdBy"] as? String
        else { return nil }
        
        var vaccination = Vaccination(
            id: id,
            petID: petID,
            vaccineName: vaccineName,
            dateAdministered: dateAdministered,
            nextDueDate: record["nextDueDate"] as? Date,
            veterinaryClinic: record["veterinaryClinic"] as? String,
            serialNumber: record["serialNumber"] as? String,
            notes: record["notes"] as? String,
            createdBy: createdBy
        )
        
        vaccination.recordID = record.recordID
        vaccination.createdAt = createdAt
        vaccination.updatedAt = updatedAt
        
        return vaccination
    }
}
