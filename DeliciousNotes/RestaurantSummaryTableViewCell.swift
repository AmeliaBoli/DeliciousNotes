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
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!

    @IBOutlet weak var firstRatingIcon: UIImageView!
    @IBOutlet weak var secondRatingIcon: UIImageView!
    @IBOutlet weak var thirdRatingIcon: UIImageView!
    @IBOutlet weak var fourthRatingIcon: UIImageView!
    @IBOutlet weak var fifthRatingIcon: UIImageView!

    @IBOutlet weak var wholeCellActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var restaurantImageLeadingConstraint: NSLayoutConstraint!

    var delegate: SearchTableDelegate?

    func configureProperties(business: Business, delegate:SearchTableDelegate?, from viewController: UIViewController) {
        wholeCellActivityIndicator.stopAnimating()
        self.delegate = delegate
        self.categoriesLabel.text = business.categories
        self.restaurantName.text = business.name

        var addButtonImage = UIImage()

        if let addToWishlistImage = UIImage(named: "add to wishlist") {
            addButtonImage = addToWishlistImage.withRenderingMode(.alwaysTemplate)
            addButton.setImage(addButtonImage, for: .normal)
        }

        if let statusString = business.status {
            switch Status(rawValue: statusString) {
            case .some(.visited), .some(.wishlist):
                if viewController is SearchViewController {
                    addButton.isHidden = false
                    restaurantImageLeadingConstraint.isActive = false
                    addButton.tintColor = .lightGray
                } else {
                    addButton.isHidden = true
                    restaurantImageLeadingConstraint.isActive = true
                    self.accessoryType = .disclosureIndicator
                }
            case .some(.search):
                addButton.isHidden = false
                restaurantImageLeadingConstraint.isActive = false
                addButton.tintColor = UIView.appearance().tintColor
            default: break
            }
        }

        var restaurantRatingImages = [UIImage]()

        if business.userRatingWasSet {
            restaurantRatingImages = Rating.ratingImages(rating: business.userRating, isUserRating: true, isLargeIcons: false)
            numberOfReviewsLabel.isHidden = true
        } else {
            restaurantRatingImages = Rating.ratingImages(rating: business.yelpRating, isUserRating: false, isLargeIcons: false)
            numberOfReviewsLabel.isHidden = false
            self.numberOfReviewsLabel.text = "\(business.reviewCount) Reviews"
        }
        firstRatingIcon.image = restaurantRatingImages[0]
        secondRatingIcon.image = restaurantRatingImages[1]
        thirdRatingIcon.image = restaurantRatingImages[2]
        fourthRatingIcon.image = restaurantRatingImages[3]
        fifthRatingIcon.image = restaurantRatingImages[4]
        
        self.selectionStyle = .none
    }

    func configureBlankCell() {
        addButton.isHidden = true
        restaurantImageLeadingConstraint.isActive = true

        restaurantImage.image = nil
        restaurantName.text = ""
        numberOfReviewsLabel.text = ""
        categoriesLabel.text = ""
        firstRatingIcon.image = nil
        secondRatingIcon.image = nil
        thirdRatingIcon.image = nil
        fourthRatingIcon.image = nil
        fifthRatingIcon.image = nil

        self.accessoryType = .none

        wholeCellActivityIndicator.startAnimating()
    }

    @IBAction func addPressed(_ sender: UIButton) {
        addButton.tintColor = .lightGray
        delegate?.addPressed(from: self)
    }
}
