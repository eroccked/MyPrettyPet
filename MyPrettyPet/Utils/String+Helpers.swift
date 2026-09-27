//
//  String+Helpers.swift
//  MyPrettyPet
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// nil, якщо рядок порожній або з самих пробілів
    var nilIfBlank: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}
