//
//  Business.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/25/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreData

enum Status: String {
    case search
    case wishlist
    case visited
}

extension Business {
    // Init
    convenience init?(dictionary: [String: Any], status: Status, context: NSManagedObjectContext) {
        self.init(context: context)

        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let rating = dictionary["rating"] as? Double,
            let reviewCount = dictionary["review_count"] as? Int64,
            let isClosed = dictionary["is_closed"] as? Bool,
            let yelpUrl = dictionary["url"] as? String,
            let imageUrl = dictionary["image_url"] as? String,
            let categories = dictionary["categories"] as? [[String: String]],
            let location = dictionary["location"] as? [String: Any] else {
                #if DEBUG
                    print("A business was missing something out of \(dictionary)")
                #endif
                return nil
        }

        self.id = id
        self.name = name
        self.status = status.rawValue
        self.yelpRating = rating
        self.isClosed = isClosed
        self.reviewCount = reviewCount
        self.yelpUrl = yelpUrl
        self.imageUrl = imageUrl

        if let phone = dictionary["phone"] as? String {
            self.phone = phone
        }
        
        guard let locationObject = Location(dictionary: location, context: context) else {
            #if DEBUG
                print("There was a problem creating the location from \(location)")
            #endif
            return nil
        }

        self.location = locationObject

        var categoriesToSave = Set<Category>()

        for (index, category) in categories.enumerated() {
            guard let newCategory = Category(dictionary: category, context: context) else {
                #if DEBUG
                    print("There was a problem creating the category from \(category)")
                #endif
                return nil
            }

            if index == 0 {
                self.preferredCategory = newCategory.title
            }

            categoriesToSave.insert(newCategory)
        }
        self.addToCategory(categoriesToSave as NSSet)
    }

    convenience init(business: Business, status: Status, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = business.id
        self.name = business.name
        self.status = status.rawValue
        self.yelpRating = business.yelpRating
        self.isClosed = business.isClosed
        self.reviewCount = business.reviewCount
        self.yelpUrl = business.yelpUrl
        self.imageUrl = business.imageUrl
        self.phone = business.phone
        self.preferredCategory = business.preferredCategory
        self.noFoundImage = business.noFoundImage
        self.userRating = business.userRating
        self.userRatingWasSet = business.userRatingWasSet

        if let location = business.location {
            self.location = Location(location: location, context: context)
        }

        var categoriesToSave = Set<Category>()

        if let categories = business.category {
            for categoryElement in categories {
                if let category = categoryElement as? Category {
                    let copiedCategory = Category(category: category, context: context)
                    categoriesToSave.insert(copiedCategory)
                }
            }
            self.addToCategory(categoriesToSave as NSSet)
        }
    }

    // Creates a string of all associated categories in a comma separated list
    var categories: String {
        var categoriesString = ""

        guard let categorySet = self.category else {
            return categoriesString
        }
        for category in categorySet {
            if let title = (category as! Category).title {
                if categoriesString.isEmpty {
                    categoriesString += title
                } else {
                    categoriesString += ", \(title)"
                }
            }
        }
        return categoriesString
    }

    // Update
    func update(dictionary: [String: Any], context: NSManagedObjectContext) -> Bool {
        guard let name = dictionary["name"] as? String,
            let phone = dictionary["phone"] as? String,
            let rating = dictionary["rating"] as? Double,
            let reviewCount = dictionary["review_count"] as? Int64,
            let isClosed = dictionary["is_closed"] as? Bool,
            let yelpUrl = dictionary["url"] as? String,
            let imageUrl = dictionary["image_url"] as? String,
            let categories = dictionary["categories"] as? [[String: String]],
            let location = dictionary["location"] as? [String: Any] else {
                #if DEBUG
                    print("A business was missing something out of \(dictionary)")
                #endif
                return false
        }

        self.name = name
        self.phone = phone
        self.yelpRating = rating
        self.isClosed = isClosed
        self.reviewCount = reviewCount
        self.yelpUrl = yelpUrl
        self.imageUrl = imageUrl

        guard let locationObject = Location(dictionary: location, context: context) else {
            #if DEBUG
                print("There was a problem creating the location from \(location)")
            #endif
            return false
        }

        self.location = locationObject

        var categoriesToSave = Set<Category>()

        for category in categories {
            guard let newCategory = Category(dictionary: category, context: context) else {
                #if DEBUG
                    print("There was a problem creating the category from \(category)")
                #endif
                return false
            }
            categoriesToSave.insert(newCategory)
        }
        self.addToCategory(categoriesToSave as NSSet)
        return true
    }

    // Creates a formatted phone number
    func displayPhone() -> String {
        guard var phone = self.phone,
            phone.characters.count == 12 else {
            return ""
        }

        phone.removeSubrange(phone.startIndex...phone.index(phone.startIndex, offsetBy: 1))
        phone.insert("(", at: phone.startIndex)

        let areaCodeEndCharacters = (") ").characters
        phone.insert(contentsOf: areaCodeEndCharacters, at: phone.index(phone.startIndex, offsetBy: 4))

        phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 9))

        return phone
    }
}
