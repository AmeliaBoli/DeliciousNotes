//
//  WishlistViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreData

class WishlistViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var restaurantTableView: CoreDataTableView!
    @IBOutlet weak var sortingSegmentedControl: UISegmentedControl!

    let yelpInterface = YelpInterface.sharedInstance
    var dataSource: UITableViewDataSource!
    var delegate: UITableViewDelegate!
    var stack: CoreDataStack!
    var sortManager = Sort.shared

    let sortByRating = [NSSortDescriptor(key: "yelpRating", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
    let sortByName = [NSSortDescriptor(key: "name", ascending: true)]
    let sortByCategory = [NSSortDescriptor(key: "preferredCategory", ascending: true), NSSortDescriptor(key: "yelpRating", ascending: false), NSSortDescriptor(key: "name", ascending: true)]

    var restaurantImages = [[String: Any?]]()

    var status = Status.wishlist

    override func viewDidLoad() {
        super.viewDidLoad()

        if let sortCategory = sortManager.retrieveCategory(for: status) {
            sortingSegmentedControl.selectedSegmentIndex = sortCategory.rawValue
        }

        navigationController?.setNavigationBarHidden(true, animated: false)

        restaurantTableView.register(UINib(nibName: "RestaurantSummaryCell", bundle: nil),forCellReuseIdentifier: "restaurantCell")

        // Get the stack
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let stack = appDelegate.stack else {
            fatalError("Could not find the AppDelegate or Core Data Stack")
        }
        self.stack = stack

        // Create the fetch request
        let fetchRequest: NSFetchRequest<Business> = Business.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status = '\(Status.wishlist.rawValue)'")

        switch SortCategory(rawValue: sortingSegmentedControl.selectedSegmentIndex) {
        case .some(.rating): fetchRequest.sortDescriptors = sortByRating
        case .some(.name): fetchRequest.sortDescriptors = sortByName
        default: fetchRequest.sortDescriptors = sortByRating
        }

        fetchRequest.sortDescriptors = sortByRating

        // Create a fetched results controller
        restaurantTableView.fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

        if let numberOfRestaurants = self.restaurantTableView.fetchedResultsController?.fetchedObjects?.count {
            self.restaurantImages = Array(repeating: ["id": nil, "image": nil], count: numberOfRestaurants)
        }
        //print(" LOOK \(restaurantTableView.fetchedResultsController?.fetchedObjects)")

        if !(UIApplication.shared.delegate as! AppDelegate).existingWishlistDataUpdated,
            let businesses = restaurantTableView.fetchedResultsController?.fetchedObjects as? [Business] {
            for business in businesses {
                if let businessId = business.id {
                    yelpInterface.fetchBusiness(businessId: businessId) { success, error in
                        guard success,
                            error == nil else {
                                #if DEBUG
                                    print("There was a problem retrieving business \(businessId): \(error)")
                                #endif
                                // TODO: Present info to the user
                                return
                        }
                        DispatchQueue.global().async {
                            for (index, restaurant) in businesses.enumerated() {
                                let nextImage = restaurant.generateImage()
                                self.restaurantImages[index]["id"] = restaurant.id
                                self.restaurantImages[index]["image"] = nextImage
                                DispatchQueue.main.async {
                                    if let businessIndex = self.restaurantTableView.fetchedResultsController?.indexPath(forObject: restaurant) { //self.searchResults.index(where: { $0.id = restaurant.id } )
                                        self.restaurantTableView.reloadRows(at: [businessIndex], with: .none)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        dataSource = self //RestaurantListDataSource(resultsController: restaurantTableView.fetchedResultsController!)
        delegate = self
        restaurantTableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let sortCategory = SortCategory(rawValue: sortingSegmentedControl.selectedSegmentIndex) {
            sortManager.save(category: sortCategory, for: status)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let sortCategory = SortCategory(rawValue: sortingSegmentedControl.selectedSegmentIndex) {
            sortManager.save(category: sortCategory, for: status)
        }
    }

    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        if let sortCategory = SortCategory(rawValue: sender.selectedSegmentIndex) {
            sortManager.save(category: sortCategory, for: status)
        }
        switch sender.selectedSegmentIndex {
        case 0:
            restaurantTableView.fetchedResultsController?.fetchRequest.sortDescriptors = sortByRating
            restaurantTableView.executeSearch()
            restaurantTableView.reloadData()

        case 1:
            restaurantTableView.fetchedResultsController?.fetchRequest.sortDescriptors = sortByName
            restaurantTableView.executeSearch()
            restaurantTableView.reloadData()

        case 2:
            restaurantTableView.fetchedResultsController?.fetchRequest.sortDescriptors = sortByCategory
            // Create the fetch request
            restaurantTableView.fetchedResultsController = nil
            let fetchRequest: NSFetchRequest<Business> = Business.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "status = '\(Status.wishlist.rawValue)'")
            fetchRequest.sortDescriptors = sortByCategory
            // Create a fetched results controller
           restaurantTableView.fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            restaurantTableView.executeSearch()
            restaurantTableView.reloadData()
        default: return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func findImageInDictionary(forBusiness id: String) -> UIImage? {
        if let imageIndex = restaurantImages.index(where: { dictionary in
            if let idFromArray = dictionary["id"] as? String,
                idFromArray == id {
                return true
            } else {
                return false
            }
        }) {
            return restaurantImages[imageIndex]["image"] as? UIImage
        } else {
            return nil
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantSummaryTableViewCell

        guard let business = restaurantTableView.fetchedResultsController?.object(at: indexPath) as? Business else {
            return cell
        }
        cell.configureProperties(business: business, delegate: self, from: self)

        if let id = business.id,
            let image = findImageInDictionary(forBusiness: id) {
            cell.restaurantImage.image = image
        } else {
            cell.restaurantImage.image = nil
            cell.restaurantImage.backgroundColor = UIColor.orange
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = restaurantTableView.fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = restaurantTableView.fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = restaurantTableView.fetchedResultsController {
            return fc.sections![section].name
        } else {
            return nil
        }

    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let fc = restaurantTableView.fetchedResultsController {
            return fc.section(forSectionIndexTitle: title, at: index)
        } else {
            return 0
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let fc = restaurantTableView.fetchedResultsController {
            return fc.sectionIndexTitles
        } else {
            return nil
        }
    }

}

extension WishlistViewController: SearchTableDelegate {
    func addPressed(from cell: UITableViewCell) {
        return
    }

    func yelpPressed(from cell: UITableViewCell) {
        guard let indexPath = restaurantTableView.indexPath(for: cell) else {
            return
        }

        guard let business = restaurantTableView.fetchedResultsController?.object(at: indexPath) as? Business else {
            return
        }

        let siteUrl = business.yelpUrl
        presentSite(urlString: siteUrl)
    }
}

extension WishlistViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "restaurantDetails") as? RestaurantDetailsViewController,
            let restaurant =  restaurantTableView.fetchedResultsController?.object(at: indexPath) as? Business {
            destinationVC.restaurant = restaurant
            if let id = restaurant.id {
                destinationVC.image = findImageInDictionary(forBusiness: id)
            }
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }


}
