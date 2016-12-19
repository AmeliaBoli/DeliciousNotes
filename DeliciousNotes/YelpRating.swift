//
//  YelpRating.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/17/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class YelpRating {
    static func ratingImages(rating: Double) -> [UIImage] {

        var firstImage = #imageLiteral(resourceName: "19x19_0")
        var secondImage = #imageLiteral(resourceName: "19x19_0")
        var thirdImage = #imageLiteral(resourceName: "19x19_0")
        var fourthImage = #imageLiteral(resourceName: "19x19_0")
        var fifthImage = #imageLiteral(resourceName: "19x19_0")

        switch rating {
        case 0.5:
            firstImage = #imageLiteral(resourceName: "19x19_1-5")
        case 1:
            firstImage = #imageLiteral(resourceName: "219x19_1")
        case 1.5:
            secondImage = #imageLiteral(resourceName: "19x19_1-5")
            firstImage = #imageLiteral(resourceName: "219x19_1")
        case 2:
            secondImage = #imageLiteral(resourceName: "19x19_2")
            firstImage = #imageLiteral(resourceName: "19x19_2")
        case 2.5:
            thirdImage = #imageLiteral(resourceName: "19x19_2-5")
            secondImage = #imageLiteral(resourceName: "19x19_2")
            firstImage = #imageLiteral(resourceName: "19x19_2")
        case 3.0:
            thirdImage = #imageLiteral(resourceName: "19x19_3")
            secondImage = #imageLiteral(resourceName: "19x19_3")
            firstImage = #imageLiteral(resourceName: "19x19_3")
        case 3.5:
            fourthImage = #imageLiteral(resourceName: "19x19_3-5")
            thirdImage = #imageLiteral(resourceName: "19x19_3")
            secondImage = #imageLiteral(resourceName: "19x19_3")
            firstImage = #imageLiteral(resourceName: "19x19_3")
        case 4:
            fourthImage = #imageLiteral(resourceName: "19x19_4")
            thirdImage = #imageLiteral(resourceName: "19x19_4")
            secondImage = #imageLiteral(resourceName: "19x19_4")
            firstImage = #imageLiteral(resourceName: "19x19_4")
        case 4.5:
            fifthImage = #imageLiteral(resourceName: "219x19_4-5")
            fourthImage = #imageLiteral(resourceName: "19x19_4")
            thirdImage = #imageLiteral(resourceName: "19x19_4")
            secondImage = #imageLiteral(resourceName: "19x19_4")
            firstImage = #imageLiteral(resourceName: "19x19_4")
        case 5:
            firstImage = #imageLiteral(resourceName: "19x19_5")
            secondImage = #imageLiteral(resourceName: "19x19_5")
            thirdImage = #imageLiteral(resourceName: "19x19_5")
            fourthImage = #imageLiteral(resourceName: "19x19_5")
            fifthImage = #imageLiteral(resourceName: "19x19_5")
        default: return [firstImage, secondImage, thirdImage, fourthImage, fifthImage]
        }

        return [firstImage, secondImage, thirdImage, fourthImage, fifthImage]
    }
}
