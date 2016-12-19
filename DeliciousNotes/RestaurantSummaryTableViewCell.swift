//
//  RestaurantSummaryTableViewself.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class RestaurantSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var napkinNotesIcon: UIImageView!
    @IBOutlet weak var numberOrReviewsLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!

    @IBOutlet weak var firstRatingIcon: UIImageView!
    @IBOutlet weak var secondRatingIcon: UIImageView!
    @IBOutlet weak var thirdRatingIcon: UIImageView!
    @IBOutlet weak var fourthRatingIcon: UIImageView!
    @IBOutlet weak var fifthRatingIcon: UIImageView!

    @IBOutlet weak var restaurantImageLeadingConstraint: NSLayoutConstraint!

    var delegate: SearchTableDelegate?

    var imageIndex: Int? = nil

    func configureProperties(business: Business, delegate: SearchTableDelegate, from viewController: UIViewController) {
        self.delegate = delegate
        self.categoriesLabel.text = business.categories
        self.napkinNotesIcon.isHidden = true
        self.numberOrReviewsLabel.text = "\(business.reviewCount) Reviews"
        self.restaurantName.text = business.name

        if let statusString = business.status,
            let status = Status(rawValue: statusString) {
            switch status {
            case .visited:
                if viewController is SearchViewController {
                    addButton.tintColor = .orange
                } else {
                    addButton.isHidden = true
                    restaurantImageLeadingConstraint.isActive = true
                    self.accessoryType = .disclosureIndicator
                }
            case .wishlist:
                if viewController is SearchViewController {
                    addButton.tintColor = .gray
                } else {
                    addButton.isHidden = true
                    restaurantImageLeadingConstraint.isActive = true
                    self.accessoryType = .disclosureIndicator
                }
            case .search:
                addButton.tintColor = .black
            }
        }

        self.firstRatingIcon.image = #imageLiteral(resourceName: "19x19_0") //#imageLiteral(resourceName: "10x10_0")
        self.secondRatingIcon.image = #imageLiteral(resourceName: "19x19_0")
        self.thirdRatingIcon.image = #imageLiteral(resourceName: "19x19_0")
        self.fourthRatingIcon.image = #imageLiteral(resourceName: "19x19_0")
        self.fifthRatingIcon.image = #imageLiteral(resourceName: "19x19_0")

        switch business.yelpRating {
        case 0.5:
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_1-5")
        case 1:
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_1")
        case 1.5:
            self.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_1-5")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_1")
        case 2:
            self.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
        case 2.5:
            self.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_2-5")
            self.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
        case 3.0:
            self.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
            self.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
        case 3.5:
            self.fourthRatingIcon.image = #imageLiteral(resourceName: "10x10_3-5")
            self.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
            self.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
        case 4:
            self.fourthRatingIcon.image = #imageLiteral(resourceName: "19x19_4") //#imageLiteral(resourceName: "10x10_4")
            self.thirdRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            self.secondRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
        case 4.5:
            self.fifthRatingIcon.image = #imageLiteral(resourceName: "219x19_4-5") //#imageLiteral(resourceName: "10x10_4-5")
            self.fourthRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            self.thirdRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            self.secondRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            self.firstRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
        case 5:
            self.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
            self.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
            self.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
            self.fourthRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
            self.fifthRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
        default: break
        }
    }

    @IBAction func addPressed(_ sender: UIButton) {
        addButton.tintColor = .lightGray
        delegate?.addPressed(from: self)
    }

    @IBAction func yelpPressed(_ sender: UIButton) {
        delegate?.yelpPressed(from: self)
    }
}
