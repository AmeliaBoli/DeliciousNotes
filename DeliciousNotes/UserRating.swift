//
//  UserRating.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/17/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class UserRating {
    static func ratingImages(rating: Double) -> [UIColor] {

        var firstImageA = UIColor.lightGray
        var firstImageB = UIColor.lightGray

        var secondImageA = UIColor.lightGray
        var secondImageB = UIColor.lightGray

        var thirdImageA = UIColor.lightGray
        var thirdImageB = UIColor.lightGray

        var fourthImageA = UIColor.lightGray
        var fourthImageB = UIColor.lightGray

        var fifthImageA = UIColor.lightGray
        var fifthImageB = UIColor.lightGray

        switch rating {
        case 0..<0.5: return [firstImageA, firstImageB, secondImageA, secondImageB, thirdImageA, thirdImageB, fourthImageA, fourthImageB, fifthImageA, fifthImageB]
        case 0.5..<1:
            firstImageA = .orange
        case 1..<1.5:
            firstImageA = .orange
            firstImageB = .orange
        case 1.5..<2:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
        case 2..<2.5:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
        case 2.5..<3.0:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
            thirdImageA = .orange
        case 3.0..<3.5:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
            thirdImageA = .orange
            thirdImageB = .orange
        case 3.5..<4:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
            thirdImageA = .orange
            thirdImageB = .orange
            fourthImageA = .orange
        case 4..<4.5:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
            thirdImageA = .orange
            thirdImageB = .orange
            fourthImageA = .orange
            fourthImageB = .orange
        case 4.5..<5:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
            thirdImageA = .orange
            thirdImageB = .orange
            fourthImageA = .orange
            fourthImageB = .orange
            fifthImageA = .orange
        case 5:
            firstImageA = .orange
            firstImageB = .orange
            secondImageA = .orange
            secondImageB = .orange
            thirdImageA = .orange
            thirdImageB = .orange
            fourthImageA = .orange
            fourthImageB = .orange
            fifthImageA = .orange
            fifthImageB = .orange
        default: return [firstImageA, firstImageB, secondImageA, secondImageB, thirdImageA, thirdImageB, fourthImageA, fourthImageB, fifthImageA, fifthImageB]
        }

        return [firstImageA, firstImageB, secondImageA, secondImageB, thirdImageA, thirdImageB, fourthImageA, fourthImageB, fifthImageA, fifthImageB]
    }
}
