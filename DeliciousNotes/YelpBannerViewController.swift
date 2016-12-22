//
//  YelpBannerViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/21/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class YelpBannerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func yelpPressed(_ sender: UIButton) {
        let urlString = "https://www.yelp.com"

        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
