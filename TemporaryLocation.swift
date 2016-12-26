//
//  TemporaryLocation.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

struct TemporaryLocation {
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var state: String?
    var zipCode: String?

    init?(dictionary: [String: Any]) {
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
}
