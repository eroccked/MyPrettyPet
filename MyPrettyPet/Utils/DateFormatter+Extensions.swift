//
//  DateFormatter+Extensions.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 07.01.2026.
//

import Foundation

extension DateFormatter {
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let mediumDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Date {
    
    func toString(format: String = "dd.MM.yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func toShortString() -> String {
        return DateFormatter.shortDate.string(from: self)
    }
    
    func toMediumString() -> String {
        return DateFormatter.mediumDate.string(from: self)
    }
    
    func toLongString() -> String {
        return DateFormatter.longDate.string(from: self)
    }
    
    func toShortDateTimeString() -> String {
        return DateFormatter.shortDateTime.string(from: self)
    }
    
    func toMediumDateTimeString() -> String {
        return DateFormatter.mediumDateTime.string(from: self)
    }
    
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(self)
        
        if interval < 60 {
            return "Щойно"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) хв. тому"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) год. тому"
        } else {
            let days = Int(interval / 86400)
            if days == 1 {
                return "Вчора"
            } else if days < 7 {
                return "\(days) дн. тому"
            } else {
                return toShortString()
            }
        }
    }
}
