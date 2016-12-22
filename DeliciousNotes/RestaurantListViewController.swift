//
//  RestaurantListViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreData

class RestaurantListViewController: UIViewController, UITabBarControllerDelegate, AlertDelegate {

    @IBOutlet weak var restaurantTableView: CoreDataTableView!
    @IBOutlet weak var sortingSegmentedControl: UISegmentedControl!

    let yelpInterface = YelpInterface.sharedInstance
    var stack: CoreDataStack!
    var sortManager = Sort.shared

    let sortByRating = [NSSortDescriptor(key: "yelpRating", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
    let sortByName = [NSSortDescriptor(key: "name", ascending: true)]

    var restaurantImages = [[String: Any?]]()

    var status = Status.visited

    override func viewDidLoad() {
        super.viewDidLoad()

        if let sortCategory = sortManager.retrieveCategory(for: status) {
            sortingSegmentedControl.selectedSegmentIndex = sortCategory.rawValue
        }

        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.delegate = self

        restaurantTableView.register(UINib(nibName: "RestaurantSummaryCell", bundle: nil),forCellReuseIdentifier: "restaurantCell")

        // Get the stack
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let stack = appDelegate.stack else {
            fatalError("Could not find the AppDelegate or Core Data Stack")
        }
        self.stack = stack

        // Create the fetch request
        let fetchRequest: NSFetchRequest<Business> = Business.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "status = '\(status.rawValue)'")

        switch SortCategory(rawValue: sortingSegmentedControl.selectedSegmentIndex) {
        case .some(.rating): fetchRequest.sortDescriptors = sortByRating
        case .some(.name): fetchRequest.sortDescriptors = sortByName
        default: fetchRequest.sortDescriptors = sortByRating
        }

        // Create a fetched results controller
        restaurantTableView.fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

        if let numberOfRestaurants = self.restaurantTableView.fetchedResultsController?.fetchedObjects?.count {
            self.restaurantImages = Array(repeating: ["id": nil, "image": nil], count: numberOfRestaurants)
        }

        //fetchBusinessData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)

        if let restaurant = restaurantTableView.fetchedResultsController?.fetchedObjects?.first as? Business,
            restaurant.name == nil {
            fetchBusinessData()
        }

        if restaurantTableView.fetchedResultsController?.fetchedObjects?.count != restaurantImages.count {
            fetchBusinessImages()
        }
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

    func fetchBusinessData() {
        guard let businesses = restaurantTableView.fetchedResultsController?.fetchedObjects as? [Business] else {
            return
        }

        for business in businesses {
            if let businessId = business.id {
                yelpInterface.fetchBusiness(businessId: businessId) { success, error in
                    guard success,
                        error == nil else {
                            #if DEBUG
                                print("There was a problem retrieving business \(businessId): \(error)")
                            #endif
                            DispatchQueue.main.async {
                                if let error = error {
                                    self.present(self.createNetworkingAlert(error: error), animated: true, completion: nil)
                                }
                            }
                            return
                    }
                  //  DispatchQueue.global(qos: .background).async {
                    self.fetchBusinessImages()
                //    }
                }
            }
        }
    }

    func fetchBusinessImages() {
        guard let businesses = restaurantTableView.fetchedResultsController?.fetchedObjects as? [Business] else {
            return
        }

        for (index, restaurant) in businesses.enumerated() {
            var businessToRead: Business? = nil

            restaurantTableView.fetchedResultsController?.managedObjectContext.perform {
                businessToRead = restaurant
            }

            guard let business = businessToRead else {
                return
            }

     //       DispatchQueue.global(qos: .background).async {
                let image = ImageFetcher.generateImage(imageUrl: business.yelpUrl)

                guard let nextImage = image else {
                    return
                }

                if index >= self.restaurantImages.count {
                    self.restaurantImages.append(["id": business.id, "image": nextImage])
                } else {
                    print("Array element: \(self.restaurantImages[index])")
                    print("Restaurant: \(business)")
                    self.restaurantImages[index]["id"] = business.id
                    self.restaurantImages[index]["image"] = nextImage
                }
                DispatchQueue.main.async {
                    if let businessIndex = self.restaurantTableView.fetchedResultsController?.indexPath(forObject: business) {
                        self.restaurantTableView.reloadRows(at: [businessIndex], with: .none)
                    }
                }
            }
    //}
    }

    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        if let sortCategory = SortCategory(rawValue: sender.selectedSegmentIndex) {
            sortManager.save(category: sortCategory, for: status)
        }

        switch sender.selectedSegmentIndex {
        case 0:
            restaurantTableView.fetchedResultsController?.fetchRequest.sortDescriptors = sortByRating
        case 1:
            restaurantTableView.fetchedResultsController?.fetchRequest.sortDescriptors = sortByName
        default: return
        }
        restaurantTableView.executeSearch()
        restaurantTableView.reloadData()
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

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is RestaurantListViewController {
            viewController.viewWillAppear(true)
        }
    }
}

extension RestaurantListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if let fc = restaurantTableView?.fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = restaurantTableView?.fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = restaurantTableView?.fetchedResultsController {
            return fc.sections![section].name
        } else {
            return nil
        }

    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let fc = restaurantTableView?.fetchedResultsController {
            return fc.section(forSectionIndexTitle: title, at: index)
        } else {
            return 0
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let fc = restaurantTableView?.fetchedResultsController {
            return fc.sectionIndexTitles
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = RestaurantSummaryTableViewCell()

        if let restaurantCell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantSummaryTableViewCell {
            cell = restaurantCell
        }

        guard let business = restaurantTableView.fetchedResultsController?.object(at: indexPath) as? Business else {
            return cell
        }
        
        if business.name == nil {
            cell.configureBlankCell()
        } else {
            cell.configureProperties(business: business, delegate: nil, from: self)

            if let id = business.id,
                let image = findImageInDictionary(forBusiness: id) {
                cell.restaurantImage.image = image
                cell.imageLoadingActivityIndicator.stopAnimating()
            } else {
                cell.restaurantImage.image = #imageLiteral(resourceName: "Thumbnail Placeholder")

                if business.noFoundImage {
                    cell.imageLoadingActivityIndicator.stopAnimating()
                } else {
                    cell.imageLoadingActivityIndicator.startAnimating()
                }
            }

        }
        return cell
    }

}

extension RestaurantListViewController: UITableViewDelegate {

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
