//
//  FoodType.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import CloudKit

struct FoodType: Identifiable {
    var id: UUID
    var recordID: CKRecord.ID?
    
    var petID: UUID
    var name: String
    var category: FoodCategory?
    var isActive: Bool
    
    var createdAt: Date
    var updatedAt: Date
    
    enum FoodCategory: String, Codable, CaseIterable {
        case dryFood = "Сухий корм"
        case wetFood = "Вологий корм"
        case treats = "Ласощі"
        case natural = "Натуральна їжа"
        case supplements = "Добавки"
        case other = "Інше"
    }
    
    init(
        id: UUID = UUID(),
        petID: UUID,
        name: String,
        category: FoodCategory? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.petID = petID
        self.name = name
        self.category = category
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Codable
extension FoodType: Codable {
    enum CodingKeys: String, CodingKey {
        case id, petID, name, category, isActive, createdAt, updatedAt
    }
}

// MARK: - CloudKit Extension
extension FoodType {
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: "FoodType", recordID: recordID)
        } else {
            record = CKRecord(recordType: "FoodType")
        }
        
        record["id"] = id.uuidString
        record["petID"] = petID.uuidString
        record["name"] = name
        record["category"] = category?.rawValue
        record["isActive"] = isActive ? 1 : 0
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> FoodType? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let petIDString = record["petID"] as? String,
            let petID = UUID(uuidString: petIDString),
            let name = record["name"] as? String,
            let isActiveInt = record["isActive"] as? Int,
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date
        else { return nil }
        
        let categoryString = record["category"] as? String
        let category = categoryString != nil ? FoodCategory(rawValue: categoryString!) : nil
        
        var foodType = FoodType(
            id: id,
            petID: petID,
            name: name,
            category: category,
            isActive: isActiveInt == 1
        )
        
        foodType.recordID = record.recordID
        foodType.createdAt = createdAt
        foodType.updatedAt = updatedAt
        
        return foodType
    }
}
