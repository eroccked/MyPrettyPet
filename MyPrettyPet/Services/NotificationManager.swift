//
//  NotificationManager.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import SwiftData
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let identifierPrefix = "medical-"
    /// iOS тримає не більше 64 запланованих сповіщень
    private let maxPendingCount = 60

    private init() {}

    // MARK: - Permission

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("❌ Error requesting notification permission: \(error)")
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    /// Прибрати всі медичні нагадування і запланувати заново з поточних даних.
    /// Викликається після кожної зміни і при відкритті застосунку (дані могли прийти з iCloud).
    func rescheduleAll(in context: ModelContext) async {
        let pending = await center.pendingNotificationRequests()
        let medicalIDs = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: medicalIDs)

        guard AppSettings.isRemindersEnabled else { return }

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else { return }

        let pets = (try? context.fetch(FetchDescriptor<Pet>())) ?? []
        let requests = pets
            .flatMap { pet in pet.currentReminders.flatMap { makeRequests(for: $0, petName: pet.name) } }
            .sorted { $0.date < $1.date }
            .prefix(maxPendingCount)

        for item in requests {
            do {
                try await center.add(item.request)
            } catch {
                print("❌ Error scheduling notification: \(error)")
            }
        }
    }

    private func makeRequests(for record: MedicalRecord, petName: String) -> [(date: Date, request: UNNotificationRequest)] {
        guard let dueDate = record.nextDueDate else { return [] }

        let calendar = Calendar.current
        let hour = AppSettings.reminderHourValue
        let daysBefore = AppSettings.reminderDaysBeforeValue

        var triggers: [(suffix: String, date: Date?, body: String)] = [
            ("due", calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dueDate),
             "Сьогодні час: \(record.kind.title.lowercased()) «\(record.name)» для \(petName)"),
        ]
        if daysBefore > 0 {
            let before = calendar.date(byAdding: .day, value: -daysBefore, to: dueDate) ?? dueDate
            triggers.append((
                "before",
                calendar.date(bySettingHour: hour, minute: 0, second: 0, of: before),
                "Через \(daysBefore) дн.: \(record.kind.title.lowercased()) «\(record.name)» для \(petName)"
            ))
        }

        return triggers.compactMap { trigger in
            guard let date = trigger.date, date > Date() else { return nil }

            let content = UNMutableNotificationContent()
            content.title = record.kind.title
            content.body = trigger.body
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let request = UNNotificationRequest(
                identifier: "\(identifierPrefix)\(record.id.uuidString)-\(trigger.suffix)",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )
            return (date, request)
        }
    }
}
