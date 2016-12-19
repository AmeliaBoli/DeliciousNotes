//
//  Sort.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/18/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

enum SortCategory: Int {
    case rating
    case name
}

class Sort {

    static var shared = Sort()
    private init() {}

    let userDefaults = UserDefaults.standard

    var visited: SortCategory = .rating
    var wishlist: SortCategory = .rating

    static func retrieveSortPreferences() {

    }

    func save(category: SortCategory, for status: Status) {
        let preference = ["category": category.rawValue]
        userDefaults.set(preference, forKey: status.rawValue)
    }

    func retrieveCategory(for status: Status) -> SortCategory? {
        guard let dictionary = userDefaults.dictionary(forKey: status.rawValue),
            let categoryString = dictionary["category"] as? Int,
            let category = SortCategory(rawValue: categoryString) else {
                return nil
        }
        return category
    }
}
