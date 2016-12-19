//
//  RestaurantListDataSource.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/10/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreData

class RestaurantListDataSource: NSObject, UITableViewDataSource {

    var resultsController: NSFetchedResultsController<NSFetchRequestResult>!

    init(resultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.resultsController = resultsController
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantSummaryTableViewCell

        guard let business = resultsController?.object(at: indexPath) as? Business else {
            return cell
        }
        //cell.configureProperties(business: business, delegate: WishlistViewController(), from: WishlistViewController())

//        if let image = restaurantImages[indexPath.row] {
//            cell.restaurantImage.image = image
//        } else {
//            cell.restaurantImage.backgroundColor = UIColor.orange
//        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = resultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = resultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = resultsController {
            return fc.sections![section].name
        } else {
            return nil
        }

    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let fc = resultsController {
            return fc.section(forSectionIndexTitle: title, at: index)
        } else {
            return 0
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let fc = resultsController {
            return fc.sectionIndexTitles
        } else {
            return nil
        }
    }
}
