//
//  Pet.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftUI
import CloudKit

struct Pet: Identifiable {
    var id: UUID
    var recordID: CKRecord.ID?
    
    var name: String
    var species: String
    var breed: String
    var gender: Gender
    var dateOfBirth: Date
    var photoData: Data?
    
    var furColor: String
    
    var microchipNumber: String?
    var microchipDate: Date?
    var microchipLocation: String?
    var tattooNumber: String?
    var tattooDate: Date?
    
    var vaccinationIDs: [UUID] = []
    var dewormingIDs: [UUID] = []
    var fleaTreatmentIDs: [UUID] = []
    
    var feedingRecordIDs: [UUID] = []
    
    var createdAt: Date
    var updatedAt: Date
    var ownerID: String
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Самець"
        case female = "Самка"
        case unknown = "Невідомо"
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        breed: String,
        gender: Gender,
        dateOfBirth: Date,
        photoData: Data? = nil,
        furColor: String,
        microchipNumber: String? = nil,
        microchipDate: Date? = nil,
        microchipLocation: String? = nil,
        tattooNumber: String? = nil,
        tattooDate: Date? = nil,
        ownerID: String
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.photoData = photoData
        self.furColor = furColor
        self.microchipNumber = microchipNumber
        self.microchipDate = microchipDate
        self.microchipLocation = microchipLocation
        self.tattooNumber = tattooNumber
        self.tattooDate = tattooDate
        self.ownerID = ownerID
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Codable
extension Pet: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, species, breed, gender, dateOfBirth, photoData
        case furColor, microchipNumber, microchipDate, microchipLocation
        case tattooNumber, tattooDate, vaccinationIDs, dewormingIDs
        case fleaTreatmentIDs, feedingRecordIDs, createdAt, updatedAt, ownerID
    }
}

// MARK: - CloudKit Extension
extension Pet {
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: "Pet", recordID: recordID)
        } else {
            record = CKRecord(recordType: "Pet")
        }
        
        record["id"] = id.uuidString
        record["name"] = name
        record["species"] = species
        record["breed"] = breed
        record["gender"] = gender.rawValue
        record["dateOfBirth"] = dateOfBirth
        record["furColor"] = furColor
        record["microchipNumber"] = microchipNumber
        record["microchipDate"] = microchipDate
        record["microchipLocation"] = microchipLocation
        record["tattooNumber"] = tattooNumber
        record["tattooDate"] = tattooDate
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["ownerID"] = ownerID
        
        if let photoData = photoData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try? photoData.write(to: tempURL)
            record["photo"] = CKAsset(fileURL: tempURL)
        }
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> Pet? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = record["name"] as? String,
            let species = record["species"] as? String,
            let breed = record["breed"] as? String,
            let genderString = record["gender"] as? String,
            let gender = Gender(rawValue: genderString),
            let dateOfBirth = record["dateOfBirth"] as? Date,
            let furColor = record["furColor"] as? String,
            let createdAt = record["createdAt"] as? Date,
            let updatedAt = record["updatedAt"] as? Date,
            let ownerID = record["ownerID"] as? String
        else { return nil }
        
        var pet = Pet(
            id: id,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            dateOfBirth: dateOfBirth,
            furColor: furColor,
            microchipNumber: record["microchipNumber"] as? String,
            microchipDate: record["microchipDate"] as? Date,
            microchipLocation: record["microchipLocation"] as? String,
            tattooNumber: record["tattooNumber"] as? String,
            tattooDate: record["tattooDate"] as? Date,
            ownerID: ownerID
        )
        
        pet.recordID = record.recordID
        pet.createdAt = createdAt
        pet.updatedAt = updatedAt
        
        if let photoAsset = record["photo"] as? CKAsset,
           let photoURL = photoAsset.fileURL,
           let photoData = try? Data(contentsOf: photoURL) {
            pet.photoData = photoData
        }
        
        return pet
    }
}
