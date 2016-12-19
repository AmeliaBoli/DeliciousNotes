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

class SearchViewController: UIViewController {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    let yelpInterface = YelpInterface.sharedInstance
    //var locationManager: CLLocationManager?

    var autocompleteSuggesions = [[String: Any]]()
    var searchResults = [Business]()
    var restaurantImages = [UIImage?]()

    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //TODO: Fix search bar alignment- setPositionAdjustment did nothing
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        locationManager.delegate = self
        searchResultsTableView.register(UINib(nibName: "RestaurantSummaryCell", bundle: nil),forCellReuseIdentifier: "restaurantCell")

        searchResultsTableView.estimatedRowHeight = 86
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        let currentAuthorizationStatus = CLLocationManager.authorizationStatus()
        if currentAuthorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if currentAuthorizationStatus == .denied || currentAuthorizationStatus == .restricted {
            // TODO: Show an alert
        } else if currentAuthorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    @IBAction func yelpPressed(_ sender: UIButton) {
        let urlString = "https://www.yelp.com"

        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}

extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            locationManager.stopMonitoringSignificantLocationChanges()
            // TODO: Show an alert
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

    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Show an alert
        #if DEBUG
            print("Location manager did fail with error: \(error.rawValue)")
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
                    case "alias", "title":  cell?.textLabel?.text = suggestion["title"] as? String
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
            } else {
                cell.restaurantImage.backgroundColor = UIColor.orange
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
                // TODO: Show an alert
                return
        }

        switch indexPath.section {
        case 0: let suggestion = autocompleteSuggesions[indexPath.row]
        var term: String? = nil
        var category: String? = nil
        if suggestion.keys.first == "term" || suggestion.keys.first == "business",
            let termToSearch = suggestion.values.first as? String {
            term = termToSearch
        } else if suggestion.keys.contains("alias"),
            let categoryToSearch = suggestion["alias"] as? String {
            category = categoryToSearch
        }
        yelpInterface.fetchSearchResults(term: term, category: category, latitude: latitude, longitude: longitude) { businesses, error in

            guard let businesses = businesses,
                error == nil else {
                    print(error?.rawValue)
                    return
            }

            self.searchResults = businesses
            self.restaurantImages = Array(repeating: nil, count: self.searchResults.count)

            DispatchQueue.global().async {
            for (index, restaurant) in businesses.enumerated() {
                let nextImage = restaurant.generateImage()
                self.restaurantImages[index] = nextImage
                DispatchQueue.main.async {
                    self.searchResultsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
            }

            self.autocompleteSuggesions.removeAll()

            DispatchQueue.main.async {
                tableView.reloadData()
            }
            }
        default: return
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
                // TODO: Show an alert
                return
        }

        yelpInterface.fetchAutocompleteSuggesions(searchText: searchText, latitude: latitude, longitude: longitude) { suggestions, error in
            guard let suggestions = suggestions,
                error == nil else {
                    #if DEBUG
                        print("There was a problem retrieving the suggestions: \(error)")
                    #endif
                    // TODO: Present info to the user
                    return
            }
            self.autocompleteSuggesions = suggestions
            DispatchQueue.main.async {
                self.searchResultsTableView.reloadData()
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchResults.isEmpty {
            searchResults.removeAll()
            restaurantImages.removeAll()
            searchResultsTableView.reloadSections([0], with: .automatic)
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

extension SearchViewController: SearchTableDelegate {
    func addPressed(from cell: UITableViewCell) {
        guard let indexPath = searchResultsTableView.indexPath(for: cell) else {
            return
        }

        let business = searchResults[indexPath.row]
        business.status = Status.wishlist.rawValue
        StackSingleton.sharedInstance.stack?.save()
    }

    func yelpPressed(from cell: UITableViewCell) {
        guard let indexPath = searchResultsTableView.indexPath(for: cell) else {
            return
        }

        let siteUrl = searchResults[indexPath.row].yelpUrl
        presentSite(urlString: siteUrl)
    }
}

protocol SearchTableDelegate {
    func addPressed(from cell: UITableViewCell)
    func yelpPressed(from cell: UITableViewCell)
    func presentSite(urlString: String?)
}

extension SearchTableDelegate {

    func presentSite(urlString: String?) {
        let urlString = urlString ?? "https://www.yelp.com"

        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
