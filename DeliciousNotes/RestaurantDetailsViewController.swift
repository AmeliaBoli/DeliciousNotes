//
//  RestaurantDetailsViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/17/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class RestaurantDetailsViewController: UIViewController {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var visitedButton: UIButton!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantAddressButton: UIButton!
    @IBOutlet weak var restaurantPhoneButton: UIButton!
    @IBOutlet weak var restaurantCategoriesLabel: UILabel!
    @IBOutlet weak var rating1ImageView: UIImageView!
    @IBOutlet weak var rating2ImageView: UIImageView!
    @IBOutlet weak var rating3ImageView: UIImageView!
    @IBOutlet weak var rating4ImageView: UIImageView!
    @IBOutlet weak var rating5ImageView: UIImageView!
    @IBOutlet weak var numberOfRatings: UILabel!

    var restaurant: Business!
    var image: UIImage?

    let switchWishlistImage = UIImage(named: "switch wishlist")?.withRenderingMode(.alwaysTemplate)
    let switchVisitedImage = UIImage(named: "switch visited")?.withRenderingMode(.alwaysTemplate)

    override func viewDidLoad() {
        super.viewDidLoad()

        restaurantImageView.image = image ?? #imageLiteral(resourceName: "Large Placeholder")

        if let status = restaurant.status {
            switch Status(rawValue: status) {
            case .some(.visited): visitedButton.setImage(switchWishlistImage, for: .normal)
            case .some(.wishlist): visitedButton.setImage(switchVisitedImage, for: .normal)
            default: break
            }
        }
        //visitedButton.tintColor

        restaurantNameLabel.text = restaurant.name
        restaurantAddressButton.titleLabel?.lineBreakMode = .byWordWrapping
        restaurantAddressButton.titleLabel?.textAlignment = .center

        if let street = restaurant.location?.address1,
            let city = restaurant.location?.city,
            let state = restaurant.location?.state,
            let zipCode = restaurant.location?.zipCode {
            restaurantAddressButton.setTitle("\(street)\n\(city), \(state) \(zipCode)", for: .normal)
        } else {
            restaurantAddressButton.isHidden = true
        }

        if restaurant.phone != nil {
            restaurantPhoneButton.setTitle(restaurant.displayPhone(), for: .normal)
        } else {
            restaurantPhoneButton.isHidden = true
        }

        restaurantCategoriesLabel.text = restaurant.categories

        loadRatingImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func loadRatingImages() {
        var restaurantRatingImages = [UIImage]()

        if restaurant.userRatingWasSet {
            restaurantRatingImages = Rating.ratingImages(rating: restaurant.userRating, isUserRating: true, isLargeIcons: false)
            numberOfRatings.isHidden = true
        } else {
            restaurantRatingImages = Rating.ratingImages(rating: restaurant.yelpRating, isUserRating: false, isLargeIcons: false)
            numberOfRatings.isHidden = false
            numberOfRatings.text = "\(restaurant.reviewCount) Reviews"
        }
        rating1ImageView.image = restaurantRatingImages[0]
        rating2ImageView.image = restaurantRatingImages[1]
        rating3ImageView.image = restaurantRatingImages[2]
        rating4ImageView.image = restaurantRatingImages[3]
        rating5ImageView.image = restaurantRatingImages[4]
    }

    @IBAction func visitedButtonPressed(_ sender: UIButton) {
        if let statusString = restaurant.status {
            if Status(rawValue: statusString) == .visited {
                restaurant.status = Status.wishlist.rawValue
                visitedButton.setImage(switchVisitedImage, for: .normal)
            } else if Status(rawValue: statusString) == .wishlist {
                restaurant.status = Status.visited.rawValue
                visitedButton.setImage(switchWishlistImage, for: .normal)
            }
        }
    }

    @IBAction func addressPressed(_ sender: UIButton) {
        guard let street = restaurant.location?.address1,
            let zipCode = restaurant.location?.zipCode,
            let addressUrl = ("https://maps.apple.com/?address=\(street),\(zipCode)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: addressUrl) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func phonePressed(_ sender: UIButton) {
        guard let phone = restaurant.phone,
            let url = URL(string: "tel://\(phone)") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func yelpButtonPressed(_ sender: UIButton) {
        guard let urlString = restaurant.yelpUrl,
            let url = URL(string: urlString)else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rate",
            let destinationVC = segue.destination as? RatingViewController {
            destinationVC.restaurant = restaurant
        }
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        loadRatingImages()
    }
}
