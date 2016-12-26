//
//  Location.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/25/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation
import CoreData

extension Location {
    convenience init?(dictionary: [String: Any], context: NSManagedObjectContext) {
        self.init(context: context)

        guard let address1 = dictionary["address1"] as? String,
            let city = dictionary["city"] as? String,
            let state = dictionary["state"] as? String,
            let zipCode = dictionary["zip_code"] as? String else {
                #if DEBUG
                    print("There was a problem finding the location properties in \(dictionary)")
                #endif
                return nil
        }
        self.address1 = address1
        self.city = city
        self.state = state
        self.zipCode = zipCode

        if let address2 = dictionary["address2"] as? String {
            self.address2 = address2
        } else {
            self.address2 = ""
        }

        if let address3 = dictionary["address3"] as? String {
            self.address3 = address3
        } else {
            self.address3 = ""
        }
    }

    convenience init?(location: Location, context: NSManagedObjectContext) {
        self.init(context: context)

        self.address1 = location.address1
        self.address2 = location.address2
        self.address3 = location.address3
        self.city = location.city
        self.state = location.state
        self.zipCode = location.zipCode
    }
}
