//
//  FeedingRecord.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftData

@Model
final class FeedingRecord {
    var id: UUID = UUID()
    var foodName: String = ""
    var portion: String = ""
    var dateTime: Date = Date()
    var notes: String?
    var fedByName: String?
    var createdAt: Date = Date()

    var pet: Pet?

    init(foodName: String, portion: String, dateTime: Date = Date(), notes: String? = nil, fedByName: String? = nil) {
        self.foodName = foodName
        self.portion = portion
        self.dateTime = dateTime
        self.notes = notes
        self.fedByName = fedByName
    }
}
