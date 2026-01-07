//
//  FleaTreatment.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

struct FleaTreatment: Identifiable {
    var id: UUID
    var recordID: CKRecord.ID?
    
    var petID: UUID
    var productName: String
    var dateAdministered: Date
    var nextDueDate: Date?
    var treatmentType: TreatmentType
    var notes: String?
    
    var createdAt: Date
    var updatedAt: Date
    var createdBy: String
    
    enum TreatmentType: String, Codable, CaseIterable {
        case drops = "Краплі"
        case collar = "Нашийник"
        case tablets = "Таблетки"
        case spray = "Спрей"
        case other = "Інше"
    }
    
    init(
        id: UUID = UUID(),
        petID: UUID,
        productName: String,
        dateAdministered: Date,
        nextDueDate: Date? = nil,
        treatmentType: TreatmentType,
        notes: String? = nil,
        createdBy: String
    ) {
        self.id = id
        self.petID = petID
        self.productName = productName
        self.dateAdministered = dateAdministered
        self.nextDueDate = nextDueDate
        self.treatmentType = treatmentType
        self.notes = notes
        self.createdBy = createdBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var needsReminder: Bool {
        guard let nextDueDate = nextDueDate else { return false }
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: nextDueDate).day ?? 0
        return daysUntilDue <= 7 && daysUntilDue >= 0
    }
}

// MARK: - Codable
extension FleaTreatment: Codable {
    enum CodingKeys: String, CodingKey {
        case id, petID, productName, dateAdministered, nextDueDate
        case treatmentType, notes, createdAt, updatedAt, createdBy
    }
}

// MARK: - CloudKit Extension
extension FleaTreatment {
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: "FleaTreatment", recordID: recordID)
        } else {
            record = CKRecord(recordType: "FleaTreatment")
        }
        
        record["id"] = id.uuidString
        record["petID"] = petID.uuidString
        record["productName"] = productName
        record["dateAdministered"] = dateAdministered
        record["nextDueDate"] = nextDueDate
        record["treatmentType"] = treatmentType.rawValue
        record["notes"] = notes
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["createdBy"] = createdBy
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> FleaTreatment? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let petIDString = record["petID"] as? String,
            let petID = UUID(uuidString: petIDString),
            let productName = record["productName"] as? String,
            let dateAdministered = record["dateAdministered"] as? Date,
            let treatmentTypeString = record["treatmentType"] as? String,
            let treatmentType = TreatmentType(rawValue: treatmentTypeString),
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date,
            let createdBy = record["createdBy"] as? String
        else { return nil }
        
        var fleaTreatment = FleaTreatment(
            id: id,
            petID: petID,
            productName: productName,
            dateAdministered: dateAdministered,
            nextDueDate: record["nextDueDate"] as? Date,
            treatmentType: treatmentType,
            notes: record["notes"] as? String,
            createdBy: createdBy
        )
        
        fleaTreatment.recordID = record.recordID
        fleaTreatment.createdAt = createdAt
        fleaTreatment.updatedAt = updatedAt
        
        return fleaTreatment
    }
}
