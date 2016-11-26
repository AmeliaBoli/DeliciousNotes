//
//  Category.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/25/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation
import CoreData

extension Category {
    convenience init?(dictionary: [String: String], context: NSManagedObjectContext) {
        self.init(context: context)
        guard let alias = dictionary["alias"],
            let title = dictionary["title"] else {
                #if DEBUG
                    print("There was a problem finding the category properties in \(dictionary)")
                #endif
                return nil
        }

        self.alias = alias
        self.title = title
    }
}
