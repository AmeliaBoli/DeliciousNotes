//
//  TemporaryBusiness.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

struct TemporaryBusiness {

    var id: String
    var name: String?
    var status: Status?
    var yelpRating: Double = 0
    var isClosed: Bool?
    var reviewCount: Int64?
    var yelpUrl: String?
    var imageUrl: String?
    var phone: String?
    var location: TemporaryLocation?
    var category = [TemporaryCategory]()
    var noFoundImage = false

    init?(dictionary: [String: Any]) {
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
        self.status = .search
        self.yelpRating = rating
        self.isClosed = isClosed
        self.reviewCount = reviewCount
        self.yelpUrl = yelpUrl
        self.imageUrl = imageUrl

        if let phone = dictionary["phone"] as? String {
            self.phone = phone
        }

        guard let locationObject = TemporaryLocation(dictionary: location) else {
            #if DEBUG
                print("There was a problem creating the location from \(location)")
            #endif
            return nil
        }

        self.location = locationObject

        for category in categories {
            guard let newCategory = TemporaryCategory(dictionary: category) else {
                #if DEBUG
                    print("There was a problem creating the category from \(category)")
                #endif
                return nil
            }

            self.category.append(newCategory)
        }
    }

    // Creates a string of all associated categories in a comma separated list
    var categories: String {
        var categoriesString = ""

        guard !category.isEmpty else {
            return categoriesString
        }
        for categoryObject in category {
            if let title = categoryObject.title {
                if categoriesString.isEmpty {
                    categoriesString += title
                } else {
                    categoriesString += ", \(title)"
                }
            }
        }
        return categoriesString
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
