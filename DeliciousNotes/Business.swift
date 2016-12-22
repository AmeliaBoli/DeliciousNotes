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

    // Creates the image that should be associated with the restaurant
    func generateImage() -> UIImage? {
        guard let photoUrl = imageUrl,
                let url = URL(string: photoUrl) else {
                    #if DEBUG
                        print("There was a problem creating the url from \(imageUrl)")
                    #endif
                    return nil
            }

            var imageData: NSData? = nil

            do {
                imageData = try NSData(contentsOf: url, options: .mappedIfSafe)
            } catch {
                #if DEBUG
                    print("There was a problem fetching the data from the image url: \(url). Error: \(error)")
                #endif
                return nil
            }
            
        let image = UIImage(data: imageData as! Data)
        return image
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
