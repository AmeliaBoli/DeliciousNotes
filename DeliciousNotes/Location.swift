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
    convenience init?(dictionary: [String: String], context: NSManagedObjectContext) {
        self.init(context: context)

        guard let address1 = dictionary["address1"],
            let address2 = dictionary["address2"],
            let address3 = dictionary["address3"],
            let city = dictionary["city"],
            let state = dictionary["state"],
            let zipCode = dictionary["zip_code"] else {
                #if DEBUG
                    print("There was a problem finding the location properties in \(dictionary)")
                #endif
                return nil
        }
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.city = city
        self.state = state
        self.zipCode = zipCode
    }
}
