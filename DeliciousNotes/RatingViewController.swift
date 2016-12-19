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
    @IBOutlet weak var ratingImageView1b: UIImageView!
    @IBOutlet weak var ratingImageView2a: UIImageView!
    @IBOutlet weak var ratingImageView2b: UIImageView!
    @IBOutlet weak var ratingImageView3a: UIImageView!
    @IBOutlet weak var ratingImageView3b: UIImageView!
    @IBOutlet weak var ratingImageView4a: UIImageView!
    @IBOutlet weak var ratingImageView4b: UIImageView!
    @IBOutlet weak var ratingImageView5a: UIImageView!
    @IBOutlet weak var ratingImageView5b: UIImageView!
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
        let imageColors = UserRating.ratingImages(rating: restaurant.userRating)

        ratingImageView1a.backgroundColor = imageColors[0]
        ratingImageView1b.backgroundColor = imageColors[1]
        ratingImageView2a.backgroundColor = imageColors[2]
        ratingImageView2b.backgroundColor = imageColors[3]
        ratingImageView3a.backgroundColor = imageColors[4]
        ratingImageView3b.backgroundColor = imageColors[5]
        ratingImageView4a.backgroundColor = imageColors[6]
        ratingImageView4b.backgroundColor = imageColors[7]
        ratingImageView5a.backgroundColor = imageColors[8]
        ratingImageView5b.backgroundColor = imageColors[9]
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        restaurant.userRating = Double(sender.value)
        restaurant.userRatingWasSet = true
        setRatingImageViews()
    }
}
