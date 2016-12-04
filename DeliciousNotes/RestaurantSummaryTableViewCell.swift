//
//  RestaurantSummaryTableViewCell.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class RestaurantSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var addIcon: UIImageView!
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


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
