//
//  YelpRating.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/17/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class Rating {
    static func ratingImages(rating: Double, isUserRating: Bool, isLargeIcons: Bool) -> [UIImage] {

        var zeroStar = #imageLiteral(resourceName: "20x20_0")
        var oneStar = #imageLiteral(resourceName: "20x20_1")
        var oneHalfStar = #imageLiteral(resourceName: "20x20_1-5")
        var twoStar = #imageLiteral(resourceName: "20x20_2")
        var twoHalfStar = #imageLiteral(resourceName: "20x20_2-5")
        var threeStar = #imageLiteral(resourceName: "20x20_3")
        var threeHalfStar = #imageLiteral(resourceName: "20x20_3-5")
        var fourStar = #imageLiteral(resourceName: "20x20_4")
        var fourHalfStar = #imageLiteral(resourceName: "20x20_4-5")
        var fiveStar = #imageLiteral(resourceName: "20x20_5")

        if isUserRating {
            zeroStar =      isLargeIcons ? #imageLiteral(resourceName: "ZeroFork32")        : #imageLiteral(resourceName: "ZeroFork20")
            oneStar =       isLargeIcons ? #imageLiteral(resourceName: "OneFork32")         : #imageLiteral(resourceName: "OneFork20")
            oneHalfStar =   isLargeIcons ? #imageLiteral(resourceName: "OneHalfFork32")     : #imageLiteral(resourceName: "OneHalfFork20")
            twoStar =       isLargeIcons ? #imageLiteral(resourceName: "TwoFork32")         : #imageLiteral(resourceName: "TwoFork20")
            twoHalfStar =   isLargeIcons ? #imageLiteral(resourceName: "TwoHalfFork32")     : #imageLiteral(resourceName: "TwoHalfFork20")
            threeStar =     isLargeIcons ? #imageLiteral(resourceName: "ThreeFork32")       : #imageLiteral(resourceName: "ThreeFork20")
            threeHalfStar = isLargeIcons ? #imageLiteral(resourceName: "ThreeHalfFork32")   : #imageLiteral(resourceName: "ThreeHalfFork20")
            fourStar =      isLargeIcons ? #imageLiteral(resourceName: "FourFork32")        : #imageLiteral(resourceName: "FourFork20")
            fourHalfStar =  isLargeIcons ? #imageLiteral(resourceName: "FourHalfFork32")    : #imageLiteral(resourceName: "FourFork20")
            fiveStar =      isLargeIcons ? #imageLiteral(resourceName: "FiveFork32")        : #imageLiteral(resourceName: "FiveFork20")

        }

        var firstImage = zeroStar
        var secondImage = zeroStar
        var thirdImage = zeroStar
        var fourthImage = zeroStar
        var fifthImage = zeroStar

        switch rating {
        case 0.5..<1:
            firstImage = oneHalfStar
        case 1..<1.5:
            firstImage = oneStar
        case 1.5..<2:
            secondImage = oneHalfStar
            firstImage = oneStar
        case 2..<2.5:
            secondImage = twoStar
            firstImage = twoStar
        case 2.5..<3:
            thirdImage = twoHalfStar
            secondImage = twoStar
            firstImage = twoStar
        case 3.0..<3.5:
            thirdImage = threeStar
            secondImage = threeStar
            firstImage = threeStar
        case 3.5..<4:
            fourthImage = threeHalfStar
            thirdImage = threeStar
            secondImage = threeStar
            firstImage = threeStar
        case 4..<4.5:
            fourthImage = fourStar
            thirdImage = fourStar
            secondImage = fourStar
            firstImage = fourStar
        case 4.5..<5:
            fifthImage = fourHalfStar
            fourthImage = fourStar
            thirdImage = fourStar
            secondImage = fourStar
            firstImage = fourStar
        case 5:
            firstImage = fiveStar
            secondImage = fiveStar
            thirdImage = fiveStar
            fourthImage = fiveStar
            fifthImage = fiveStar
        default: break
        }

        return [firstImage, secondImage, thirdImage, fourthImage, fifthImage]
    }
}
