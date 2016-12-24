//
//  SearchViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class SearchViewController: UIViewController, UITabBarControllerDelegate, AlertDelegate {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var centerActivityIndicator: UIActivityIndicatorView!

    let yelpInterface = YelpInterface.sharedInstance

    var autocompleteSuggesions = [[String: Any]]()
    var searchResults = [Business]()
    var restaurantImages = [UIImage?]()

    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.delegate = self
        
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        locationManager.delegate = self
        searchResultsTableView.register(UINib(nibName: "RestaurantSummaryCell", bundle: nil),forCellReuseIdentifier: "restaurantCell")

        searchResultsTableView.estimatedRowHeight = 86
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchResultsTableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        startLocationServices()
    }

    func startLocationServices() {
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        let currentAuthorizationStatus = CLLocationManager.authorizationStatus()

        if currentAuthorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if currentAuthorizationStatus == .denied || currentAuthorizationStatus == .restricted {
            showLocationServicesAlert()
        } else if currentAuthorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func showLocationServicesAlert() {
        let alert = UIAlertController(title: "Location Permissions", message: "This app requires location services to be enabled. Please check your settings in the Settings App if you would like to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is RestaurantListViewController {
            viewController.viewWillAppear(true)
        }
    }
}

extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            locationManager.stopMonitoringSignificantLocationChanges()
            showLocationServicesAlert()
        } else if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last,
            Date().timeIntervalSince(location.timestamp) < 300 {
            currentLocation = location
        } else {
            #if DEBUG
                print("There is no valid updated location")
            #endif
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
            print("Location manager did fail with error: \(error)")
        #endif
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searchResults.isEmpty {
            return searchResults.count
        } else {
            return autocompleteSuggesions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell")

            if indexPath.row < autocompleteSuggesions.count {
                let suggestion = autocompleteSuggesions[indexPath.row]

                if let firstKey = suggestion.keys.first {
                    switch firstKey {
                    case "term": cell?.textLabel?.text = suggestion["term"] as? String
                    case "alias", "title":
                        cell?.textLabel?.text = suggestion["title"] as? String
                        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                    case "business": cell?.textLabel?.text = suggestion["business"] as? String
                    default: break
                    }
                }
            }
            return cell!
        } else {
            let business = searchResults[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell") as! RestaurantSummaryTableViewCell
            cell.configureProperties(business: business, delegate: self, from: self)

            if let image = restaurantImages[indexPath.row] {
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
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchResults.isEmpty {
            return 44
        } else {
            return 86
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchResults.isEmpty {
            return 44
        } else {
            return 86
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lastLocationUpdate = currentLocation?.timestamp,
            Date().timeIntervalSince(lastLocationUpdate) < 300,
            let latitude = currentLocation?.coordinate.latitude,
            let longitude = currentLocation?.coordinate.longitude else {
                #if DEBUG
                    print("There is no location to search for")
                #endif
                return
        }

        if !autocompleteSuggesions.isEmpty {
            let suggestion = autocompleteSuggesions[indexPath.row]
            var term: String? = nil
            var category: String? = nil

            if suggestion.keys.first == "term" || suggestion.keys.first == "business",
                let termToSearch = suggestion.values.first as? String {
                term = termToSearch
            } else if suggestion.keys.contains("alias"),
                let categoryToSearch = suggestion["alias"] as? String {
                category = categoryToSearch
            }

            centerActivityIndicator.startAnimating()
            yelpInterface.fetchSearchResults(term: term, category: category, latitude: latitude, longitude: longitude) { businesses, error in

                guard let businesses = businesses,
                    error == nil else {
                        DispatchQueue.main.async {
                            self.centerActivityIndicator.stopAnimating()
                            if let error = error {
                                self.present(self.createNetworkingAlert(error: error), animated: true, completion: nil)
                            }
                        }
                        return
                }

                self.searchResults = businesses
                self.restaurantImages = Array(repeating: nil, count: self.searchResults.count)

                DispatchQueue.main.async {
                    for (index, restaurant) in businesses.enumerated() {
                        if let nextImage = ImageFetcher.generateImage(imageUrl: restaurant.imageUrl) {
                            self.restaurantImages[index] = nextImage
                        } else {
                            restaurant.noFoundImage = true
                        }
                        DispatchQueue.main.async {
                            self.searchResultsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                    }
                }

                self.autocompleteSuggesions.removeAll()

                DispatchQueue.main.async {
                    self.centerActivityIndicator.stopAnimating()
                    tableView.reloadData()
                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate, UIGestureRecognizerDelegate {
    func getSuggestions(searchText: String) {
        guard let lastLocationUpdate = currentLocation?.timestamp,
            Date().timeIntervalSince(lastLocationUpdate) < 300,
            let latitude = currentLocation?.coordinate.latitude,
            let longitude = currentLocation?.coordinate.longitude else {
                #if DEBUG
                    print("There is no location to search for")
                #endif
                return
        }
        centerActivityIndicator.startAnimating()
        yelpInterface.fetchAutocompleteSuggesions(searchText: searchText, latitude: latitude, longitude: longitude) { suggestions, error in
            guard let suggestions = suggestions,
                error == nil else {
                    #if DEBUG
                        print("There was a problem retrieving the suggestions: \(error)")
                    #endif
                    DispatchQueue.main.async {
                        self.centerActivityIndicator.stopAnimating()
                        if let error = error {
                            self.present(self.createNetworkingAlert(error: error), animated: true, completion: nil)
                        }
                    }
                    return
            }
            self.autocompleteSuggesions = suggestions
            DispatchQueue.main.async {
                self.centerActivityIndicator.stopAnimating()
                self.searchResultsTableView.reloadData()
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchResults.isEmpty {
            searchResults.removeAll()
            restaurantImages.removeAll()
            searchResultsTableView.reloadData()
        }

        if !searchText.isEmpty {
            getSuggestions(searchText: searchText)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text,
            !searchText.isEmpty {
            getSuggestions(searchText: searchText)
        }
    }
    
    @IBAction func dismissKeyboardOnTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)

        let numberOfTouches = sender.numberOfTouches
        let touchPoint = sender.location(ofTouch: (numberOfTouches - 1), in: searchResultsTableView)

        guard let indexPath = searchResultsTableView.indexPathForRow(at: touchPoint) else {
            return
        }
        searchResultsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        searchResultsTableView.delegate?.tableView!(searchResultsTableView, didSelectRowAt: indexPath)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if searchBar.isFirstResponder {
            return true
        } else {
            return false
        }
    }
}

protocol SearchTableDelegate {
    func addPressed(from cell: UITableViewCell)
}

extension SearchViewController: SearchTableDelegate {
    func addPressed(from cell: UITableViewCell) {
        guard let indexPath = searchResultsTableView.indexPath(for: cell) else {
            return
        }

        let business = searchResults[indexPath.row]
        if let statusString = business.status,
            let status = Status(rawValue: statusString),
            status == .search {
            business.status = Status.wishlist.rawValue
            StackSingleton.sharedInstance.stack?.save()
        }
    }
}
