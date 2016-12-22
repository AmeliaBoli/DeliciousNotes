//
//  ErrorEnum.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/20/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

enum Error {
    case inApp
    case jsonSerialization
    case malformedJson
    case storage
    case error(String)
}

