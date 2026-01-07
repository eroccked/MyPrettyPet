//
//  NotificationManager.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Request Permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Error requesting notification permission: \(error)")
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Schedule Medical Reminder
    func scheduleMedicalReminder(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled: \(title)")
            }
        }
    }
    
    // MARK: - Schedule Vaccination Reminder
    func scheduleVaccinationReminder(vaccination: Vaccination, petName: String, daysBefore: Int = 7) {
        guard let nextDueDate = vaccination.nextDueDate else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: nextDueDate) ?? nextDueDate
        
        let title = "Нагадування про щеплення"
        let body = "\(petName) потребує щеплення '\(vaccination.vaccineName)' через \(daysBefore) днів"
        let identifier = "vaccination-\(vaccination.id.uuidString)"
        
        scheduleMedicalReminder(title: title, body: body, date: reminderDate, identifier: identifier)
    }
    
    // MARK: - Schedule Deworming Reminder
    func scheduleDewormingReminder(deworming: Deworming, petName: String, daysBefore: Int = 3) {
        guard let nextDueDate = deworming.nextDueDate else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: nextDueDate) ?? nextDueDate
        
        let title = "Нагадування про глистування"
        let body = "\(petName) потребує глистування через \(daysBefore) днів"
        let identifier = "deworming-\(deworming.id.uuidString)"
        
        scheduleMedicalReminder(title: title, body: body, date: reminderDate, identifier: identifier)
    }
    
    // MARK: - Schedule Flea Treatment Reminder
    func scheduleFleaTreatmentReminder(fleaTreatment: FleaTreatment, petName: String, daysBefore: Int = 3) {
        guard let nextDueDate = fleaTreatment.nextDueDate else { return }
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: nextDueDate) ?? nextDueDate
        
        let title = "Нагадування про обробку від бліх"
        let body = "\(petName) потребує обробку від бліх через \(daysBefore) днів"
        let identifier = "flea-\(fleaTreatment.id.uuidString)"
        
        scheduleMedicalReminder(title: title, body: body, date: reminderDate, identifier: identifier)
    }
    
    // MARK: - Cancel Notification
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}
