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
        self.rating = rating
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

        for category in categories {
            guard let newCategory = Category(dictionary: category, context: context) else {
                #if DEBUG
                    print("There was a problem creating the category from \(category)")
                #endif
                return nil
            }
            print("##### New Category: \(newCategory)\n####")
            categoriesToSave.insert(newCategory)
        }
        print("##### Categories To Save: \(categoriesToSave)\n#####")
        self.addToCategory(categoriesToSave as NSSet)
        print("##### Saved Category: \(self.category)\n#####")
    }

    var categories: String {
        var categoriesString = ""

        guard let categorySet = self.category else {
            return categoriesString
        }
        print("#####Categories: \(categorySet)\n######")
        for category in categorySet {
            print("#####Category: \(category)\n######")
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
        self.rating = rating
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

        print(categories)
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
}
