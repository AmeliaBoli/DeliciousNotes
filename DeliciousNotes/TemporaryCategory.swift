//
//  TemporaryCategory.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

struct TemporaryCategory {
    var alias: String?
    var title: String?

    init?(dictionary: [String: String]) {
        guard let alias = dictionary["alias"],
            let title = dictionary["title"],
            let _ = YelpCategory(rawValue: title) else {
                #if DEBUG
                    print("There was a problem finding the category properties in \(dictionary) or it is not a food category")
                #endif
                return nil
        }
        self.alias = alias
        self.title = title
    }
}
