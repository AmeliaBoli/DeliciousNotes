//
//  SearchViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {

    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    let yelpInterface = YelpInterface.sharedInstance
    //var locationManager: CLLocationManager?

    var autocompleteSuggesions = [[String: Any]]()
    var searchResults = [Business]()

    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: Fix search bar alignment- setPositionAdjustment did nothing
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        locationManager.delegate = self
        searchResultsTableView.register(UINib(nibName: "RestaurantSummaryCell", bundle: nil),forCellReuseIdentifier: "restaurantCell")
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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return autocompleteSuggesions.count
        case 1: return searchResults.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let suggestion = autocompleteSuggesions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell")

            if let firstKey = suggestion.keys.first {
                switch firstKey {
                case "term": cell?.textLabel?.text = suggestion["term"] as? String
                case "alias", "title":  cell?.textLabel?.text = suggestion["title"] as? String
                cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                case "business": cell?.textLabel?.text = suggestion["business"] as? String
                default: break
                }
            }
            return cell!
        case 1:
            let business = searchResults[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell") as! RestaurantSummaryTableViewCell
            print(business.categories)
            cell.categoriesLabel.text = business.categories
            cell.napkinNotesIcon.isHidden = true
            cell.numberOrReviewsLabel.text = "\(business.reviewCount) Reviews"
            cell.restaurantName.text = business.name
            cell.restaurantImage.image = business.generateImage()

            cell.firstRatingIcon.image = #imageLiteral(resourceName: "19x19_0") //#imageLiteral(resourceName: "10x10_0")
            cell.secondRatingIcon.image = #imageLiteral(resourceName: "19x19_0")
            cell.thirdRatingIcon.image = #imageLiteral(resourceName: "19x19_0")
            cell.fourthRatingIcon.image = #imageLiteral(resourceName: "19x19_0")
            cell.fifthRatingIcon.image = #imageLiteral(resourceName: "19x19_0")

            switch business.rating {
            case 0.5:
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_1-5")
            case 1:
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_1")
            case 1.5:
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_1-5")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_1")
            case 2:
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
            case 2.5:
                cell.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_2-5")
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_2")
            case 3.0:
                cell.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
            case 3.5:
                cell.fourthRatingIcon.image = #imageLiteral(resourceName: "10x10_3-5")
                cell.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_3")
            case 4:
                cell.fourthRatingIcon.image = #imageLiteral(resourceName: "19x19_4") //#imageLiteral(resourceName: "10x10_4")
                cell.thirdRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            case 4.5:
                cell.fifthRatingIcon.image = #imageLiteral(resourceName: "219x19_4-5") //#imageLiteral(resourceName: "10x10_4-5")
                cell.fourthRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
                cell.thirdRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "19x19_4")
            case 5:
                cell.firstRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
                cell.secondRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
                cell.thirdRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
                cell.fourthRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
                cell.fifthRatingIcon.image = #imageLiteral(resourceName: "10x10_5")
            default: break
            }
            return cell
        default: return UITableViewCell()
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 44
        case 1: return 86
        default: return 44
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
            self.autocompleteSuggesions.removeAll()

            DispatchQueue.main.async {
                tableView.reloadData()
            }
            }
        default: return
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
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
            print(self.autocompleteSuggesions)
            DispatchQueue.main.async {
                self.searchResultsTableView.reloadData()
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchResults.isEmpty {
            searchResults.removeAll()
            searchResultsTableView.reloadSections([1], with: .automatic)
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
}
