//
//  MedicalCloudKitService.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//


import Foundation
import CloudKit

class MedicalCloudKitService {
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    
    init() {
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Vaccination
    
    /// Зберегти щеплення
    func saveVaccination(_ vaccination: Vaccination, completion: @escaping (Result<Vaccination, Error>) -> Void) {
        let record = vaccination.toCKRecord()
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let savedRecord = savedRecord,
                  let updatedVaccination = Vaccination.fromCKRecord(savedRecord) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.conversionFailed))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(updatedVaccination))
            }
        }
    }
    
    /// Отримати всі щеплення для тварини
    func fetchVaccinations(for petID: UUID, completion: @escaping (Result<[Vaccination], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@", petID.uuidString)
        let query = CKQuery(recordType: "Vaccination", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "dateAdministered", ascending: false)]
        
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
            
            let vaccinations = records.compactMap { Vaccination.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(vaccinations))
            }
        }
    }
    
    /// Отримати щеплення які потребують нагадування
    func fetchUpcomingVaccinations(for petID: UUID, completion: @escaping (Result<[Vaccination], Error>) -> Void) {
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        
        let predicate = NSPredicate(format: "petID == %@ AND nextDueDate != nil AND nextDueDate <= %@ AND nextDueDate >= %@",
                                   petID.uuidString,
                                   futureDate as NSDate,
                                   Date() as NSDate)
        let query = CKQuery(recordType: "Vaccination", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "nextDueDate", ascending: true)]
        
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
            
            let vaccinations = records.compactMap { Vaccination.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(vaccinations))
            }
        }
    }
    
    /// Видалити щеплення
    func deleteVaccination(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    // MARK: - Deworming
    
    /// Зберегти глистування
    func saveDeworming(_ deworming: Deworming, completion: @escaping (Result<Deworming, Error>) -> Void) {
        let record = deworming.toCKRecord()
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let savedRecord = savedRecord,
                  let updatedDeworming = Deworming.fromCKRecord(savedRecord) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.conversionFailed))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(updatedDeworming))
            }
        }
    }
    
    /// Отримати всі записи глистування для тварини
    func fetchDewormings(for petID: UUID, completion: @escaping (Result<[Deworming], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@", petID.uuidString)
        let query = CKQuery(recordType: "Deworming", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "dateAdministered", ascending: false)]
        
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
            
            let dewormings = records.compactMap { Deworming.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(dewormings))
            }
        }
    }
    
    /// Отримати глистування які потребують нагадування
    func fetchUpcomingDewormings(for petID: UUID, completion: @escaping (Result<[Deworming], Error>) -> Void) {
        let futureDate = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        
        let predicate = NSPredicate(format: "petID == %@ AND nextDueDate != nil AND nextDueDate <= %@ AND nextDueDate >= %@",
                                   petID.uuidString,
                                   futureDate as NSDate,
                                   Date() as NSDate)
        let query = CKQuery(recordType: "Deworming", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "nextDueDate", ascending: true)]
        
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
            
            let dewormings = records.compactMap { Deworming.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(dewormings))
            }
        }
    }
    
    /// Видалити глистування
    func deleteDeworming(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    // MARK: - Flea Treatment
    
    /// Зберегти обробку від бліх
    func saveFleaTreatment(_ fleaTreatment: FleaTreatment, completion: @escaping (Result<FleaTreatment, Error>) -> Void) {
        let record = fleaTreatment.toCKRecord()
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let savedRecord = savedRecord,
                  let updatedFleaTreatment = FleaTreatment.fromCKRecord(savedRecord) else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitManager.CloudKitError.conversionFailed))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(updatedFleaTreatment))
            }
        }
    }
    
    /// Отримати всі обробки від бліх для тварини
    func fetchFleaTreatments(for petID: UUID, completion: @escaping (Result<[FleaTreatment], Error>) -> Void) {
        let predicate = NSPredicate(format: "petID == %@", petID.uuidString)
        let query = CKQuery(recordType: "FleaTreatment", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "dateAdministered", ascending: false)]
        
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
            
            let fleaTreatments = records.compactMap { FleaTreatment.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(fleaTreatments))
            }
        }
    }
    
    /// Отримати обробки від бліх які потребують нагадування
    func fetchUpcomingFleaTreatments(for petID: UUID, completion: @escaping (Result<[FleaTreatment], Error>) -> Void) {
        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        let predicate = NSPredicate(format: "petID == %@ AND nextDueDate != nil AND nextDueDate <= %@ AND nextDueDate >= %@",
                                   petID.uuidString,
                                   futureDate as NSDate,
                                   Date() as NSDate)
        let query = CKQuery(recordType: "FleaTreatment", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "nextDueDate", ascending: true)]
        
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
            
            let fleaTreatments = records.compactMap { FleaTreatment.fromCKRecord($0) }
            
            DispatchQueue.main.async {
                completion(.success(fleaTreatments))
            }
        }
    }
    
    /// Видалити обробку від бліх
    func deleteFleaTreatment(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    // MARK: - Combined Medical Records
    
    /// Отримати всі медичні записи які потребують нагадування
    func fetchAllUpcomingMedicalRecords(for petID: UUID, completion: @escaping (Result<MedicalReminders, Error>) -> Void) {
        let group = DispatchGroup()
        
        var vaccinations: [Vaccination] = []
        var dewormings: [Deworming] = []
        var fleaTreatments: [FleaTreatment] = []
        
        var fetchError: Error?
        
        // Fetch vaccinations
        group.enter()
        fetchUpcomingVaccinations(for: petID) { result in
            switch result {
            case .success(let items):
                vaccinations = items
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        // Fetch dewormings
        group.enter()
        fetchUpcomingDewormings(for: petID) { result in
            switch result {
            case .success(let items):
                dewormings = items
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        // Fetch flea treatments
        group.enter()
        fetchUpcomingFleaTreatments(for: petID) { result in
            switch result {
            case .success(let items):
                fleaTreatments = items
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                let reminders = MedicalReminders(
                    vaccinations: vaccinations,
                    dewormings: dewormings,
                    fleaTreatments: fleaTreatments
                )
                completion(.success(reminders))
            }
        }
    }
    
    // MARK: - Helper Struct
    struct MedicalReminders {
        let vaccinations: [Vaccination]
        let dewormings: [Deworming]
        let fleaTreatments: [FleaTreatment]
        
        var hasReminders: Bool {
            return !vaccinations.isEmpty || !dewormings.isEmpty || !fleaTreatments.isEmpty
        }
        
        var totalCount: Int {
            return vaccinations.count + dewormings.count + fleaTreatments.count
        }
    }
}
