//
//  Business.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/25/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation
import CoreData

enum Status: String {
    case search
    case wishlist
    case visited
}

extension Business {
    convenience init?(dictionary: [String: Any], status: Status, context: NSManagedObjectContext) {
        self.init(context: context)

        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let phone = dictionary["phone"] as? String,
            let rating = dictionary["rating"] as? Int64,
            let reviewCount = dictionary["review_count"] as? Int64,
            let isClosed = dictionary["is_closed"] as? Bool,
            let yelpUrl = dictionary["url"] as? String,
            let imageUrl = dictionary["image_url"] as? String,
            let categories = dictionary["categories"] as? [[String: String]],
            let location = dictionary["location"] as? [String: String] else {
                #if DEBUG
                    print("A business was missing something out of \(dictionary)")
                #endif
                return nil
        }

        self.id = id
        self.name = name
        self.status = status.rawValue
        self.phone = phone
        self.rating = rating
        self.isClosed = isClosed
        self.reviewCount = reviewCount
        self.yelpUrl = yelpUrl
        self.imageUrl = imageUrl

        guard let locationObject = Location(dictionary: location, context: context) else {
            #if DEBUG
                print("There was a problem creating the location from \(location)")
            #endif
            return nil
        }

        self.location = locationObject

        var categoriesToSave = Set<Category>()

        for category in categories {
            guard let newCategory = Category(dictionary: category, context: context) else {
                #if DEBUG
                    print("There was a problem creating the category from \(category)")
                #endif
                return nil
            }
            categoriesToSave.insert(newCategory)
        }
        self.addToCategory(categoriesToSave as NSSet)
    }
}
