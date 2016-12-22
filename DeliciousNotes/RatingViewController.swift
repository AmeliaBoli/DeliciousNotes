//
//  RatingViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/17/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var ratingImageView1a: UIImageView!
    @IBOutlet weak var ratingImageView2a: UIImageView!
    @IBOutlet weak var ratingImageView3a: UIImageView!
    @IBOutlet weak var ratingImageView4a: UIImageView!
    @IBOutlet weak var ratingImageView5a: UIImageView!
    @IBOutlet weak var ratingSlider: UISlider!

    var restaurant: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let restaurantName = restaurant.name {
            restaurantNameLabel.text = "Your Rating For \(restaurantName)"
        } else {
            restaurantNameLabel.text = "Your Rating"
        }

        ratingSlider.value = Float(restaurant.userRating)

        setRatingImageViews()
    }

    func setRatingImageViews() {
        let imageColors = Rating.ratingImages(rating: restaurant.userRating, isUserRating: true, isLargeIcons: true)

        ratingImageView1a.image = imageColors[0]
        ratingImageView2a.image = imageColors[1]
        ratingImageView3a.image = imageColors[2]
        ratingImageView4a.image = imageColors[3]
        ratingImageView5a.image = imageColors[4]
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        restaurant.userRating = Double(sender.value)
        restaurant.userRatingWasSet = true
        setRatingImageViews()
    }
}
