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
    @IBOutlet weak var editButton: UIBarButtonItem!

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let restaurant = restaurantTableView.fetchedResultsController?.fetchedObjects?.first as? Business,
            restaurant.name == nil {
            fetchBusinessData()
        } else if restaurantTableView.fetchedResultsController?.fetchedObjects?.count != restaurantImages.count || restaurantImagesHasEmptyImages() {
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

    func restaurantImagesHasEmptyImages() -> Bool {
        guard !restaurantImages.isEmpty else {
            return false
        }

        if let _ = restaurantImages.first(where: { $0["image"] == nil }) {
            return true
        } else {
            return false
        }
    }

    func fetchBusinessData() {
        guard let businesses = restaurantTableView.fetchedResultsController?.fetchedObjects as? [Business] else {
            return
        }

        let fetchBusinessDispatchGroup = DispatchGroup()

        for business in businesses {
            if let businessId = business.id {
                fetchBusinessDispatchGroup.enter()
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
                    fetchBusinessDispatchGroup.leave()
                }
            }
        }
                fetchBusinessDispatchGroup.notify(queue: .main) {
                    self.fetchBusinessImages()
        }

    }

    func fetchBusinessImages() {
        guard let businesses = restaurantTableView.fetchedResultsController?.fetchedObjects as? [Business] else {
            return
        }

        for restaurant in businesses {
            let restaurantId = restaurant.id
            let imageDictionaries = restaurantImages.filter({ ($0["id"] as? String) == restaurantId })
            if imageDictionaries.isEmpty || imageDictionaries.first?["image"] == nil {

                var imageDictionary: [String: Any?] = ["id": restaurantId]

                DispatchQueue.global(qos: .utility).async {
                    self.restaurantTableView.fetchedResultsController?.managedObjectContext.performAndWait {
                        let image = ImageFetcher.generateImage(imageUrl: restaurant.imageUrl)

                        guard let nextImage = image else {
                            restaurant.noFoundImage = true
                            DispatchQueue.main.async {
                                if let businessIndex = self.restaurantTableView.fetchedResultsController?.indexPath(forObject: restaurant) {
                                    self.restaurantTableView.reloadRows(at: [businessIndex], with: .none)
                                }
                            }
                            return
                        }

                        imageDictionary["image"] = nextImage

                        if let imageIndex = self.restaurantImages.index(where: { dictionary in
                            if let idFromArray = dictionary["id"] as? String,
                                idFromArray == restaurantId {
                                return true
                            } else {
                                return false
                            }
                        }) {
                            self.restaurantImages[imageIndex] = imageDictionary
                        } else {
                            self.restaurantImages.append(imageDictionary)
                        }

                        DispatchQueue.main.async {
                            if let businessIndex = self.restaurantTableView.fetchedResultsController?.indexPath(forObject: restaurant) {
                                self.restaurantTableView.reloadRows(at: [businessIndex], with: .none)
                            }
                        }
                    }
                }
            }
        }
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

    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        if restaurantTableView.isEditing {
            restaurantTableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        } else {
            restaurantTableView.setEditing(true, animated: true)
            editButton.title = "Done"
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let restaurantToDelete = restaurantTableView.fetchedResultsController?.object(at: indexPath) as? Business {
            restaurantTableView.fetchedResultsController?.managedObjectContext.delete(restaurantToDelete)
        }
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
