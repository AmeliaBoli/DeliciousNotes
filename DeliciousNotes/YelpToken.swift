//
//  YelpToken.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/20/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

class YelpToken {

    // MARK: Singleton
    static var sharedInstance = YelpToken()
    private init() { }

    // MARK: Properties
    private var tokenId: String = ""
    private var expirationDate: Date = Date(timeIntervalSince1970: 0)

    // MARK: Methods
    func set(newToken: String, newExpirationDate: Date) {
        self.tokenId = newToken
        self.expirationDate = newExpirationDate
    }

    func getTokenId() -> String {
        return self.tokenId
    }

    func getExpirationDate() -> Date {
        return self.expirationDate
    }

    func isValid() -> Bool {
        return self.expirationDate > Date()
    }
}
