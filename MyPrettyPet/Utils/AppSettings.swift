//
//  AppSettings.swift
//  MyPrettyPet
//

import Foundation

/// Ключі UserDefaults / @AppStorage
enum AppSettings {
    static let ownerName = "ownerName"
    static let selectedPetID = "selectedPetID"
    static let remindersEnabled = "remindersEnabled"
    static let reminderDaysBefore = "reminderDaysBefore"
    static let reminderHour = "reminderHour"

    static let defaultReminderDaysBefore = 3
    static let defaultReminderHour = 10

    static var isRemindersEnabled: Bool {
        UserDefaults.standard.object(forKey: remindersEnabled) as? Bool ?? true
    }

    static var reminderDaysBeforeValue: Int {
        UserDefaults.standard.object(forKey: reminderDaysBefore) as? Int ?? defaultReminderDaysBefore
    }

    static var reminderHourValue: Int {
        UserDefaults.standard.object(forKey: reminderHour) as? Int ?? defaultReminderHour
    }
}
