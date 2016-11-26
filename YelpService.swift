//
//  YelpService.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/20/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation
import CoreData

struct AutocompleteSuggestion {
    var terms: [String] = []
    var categories: [Category] = []
    var businesses: [Business] = []
}

//struct Category {
//    var alias: String = ""
//    var title: String = ""
//
//    init(dictionary: [String: String]) {
//        if let alias = dictionary["alias"] {
//            self.alias = alias
//        }
//
//        if let title = dictionary["title"] {
//            self.title = title
//        }
//    }
//}
//
//struct Business {
//    var name: String = ""
//    var id: String = ""
//    var rating: Int = 0
//    var phone: String = ""
//    var isClosed: Bool = false
//    var categories: [Category] = []
//    var reviewCount: Int = 0
//    var yelpUrl: String = ""
//    var imageUrl: String = ""
//    var location: Location = Location(dictionary: [:])
//
//    init(dictionary: [String: Any]) {
//        if let name = dictionary["name"] as? String {
//            self.name = name
//        }
//
//        if let id = dictionary["id"] as? String {
//            self.id = id
//        }
//
//        if let rating = dictionary["rating"] as? Int {
//            self.rating = rating
//        }
//
//        if let phone = dictionary["phone"] as? String {
//            self.phone = phone
//        }
//
//        if let isClosed = dictionary["isClosed"] as? Bool {
//            self.isClosed = isClosed
//        }
//
//        if let categories = dictionary["categories"] as? [[String: String]] {
//            var categoriesToSave = [Category]()
//
//            for category in categories {
//                let newCategory = Category(dictionary: category)
//                categoriesToSave.append(newCategory)
//            }
//
//            self.categories = categoriesToSave
//        }
//
//        if let reviewCount = dictionary["review_count"] as? Int {
//            self.reviewCount = reviewCount
//        }
//
//        if let yelpUrl = dictionary["url"] as? String {
//            self.yelpUrl = yelpUrl
//        }
//
//        if let imageUrl = dictionary["image_url"] as? String {
//            self.imageUrl = imageUrl
//        }
//
//        if let location = dictionary["location"] as? [String: String] {
//            self.location = Location(dictionary: location)
//        }
//    }
//}
//
//struct Location {
//    var address1: String = ""
//    var address2: String = ""
//    var address3: String = ""
//    var city: String = ""
//    var state: String = ""
//    var zipCode: String = ""
//
//    init(dictionary: [String: String]) {
//        if let address1 = dictionary["address1"] {
//            self.address1 = address1
//        }
//
//        if let address2 = dictionary["address2"] {
//            self.address2 = address2
//        }
//
//        if let address3 = dictionary["address3"] {
//            self.address3 = address3
//        }
//
//        if let city = dictionary["city"] {
//            self.city = city
//        }
//
//        if let state = dictionary["state"] {
//            self.state = state
//        }
//
//        if let zipCode = dictionary["zip_code"] {
//            self.zipCode = zipCode
//        }
//    }
//}

class YelpService: Networking {

    // MARK: Singleton
    static var sharedInstance = YelpService()
    private init() { }

    // MARK: Properties
    // Core Data Stack
    let stack = StackSingleton.sharedInstance.stack!

    // Token
    let token = YelpToken.sharedInstance

    // Constansts
    struct Constants {
        static let AppId = "8I3oFFNDqMzy8oFCpCW5_g"
        static let AppSecret = "yOpL7k7ZZlUXeUHffjQPXj6x2DFs77dDdY0xb1kdhwalUmdFlGkAcUDL0KBj7cB6"
        static let Scheme = "https"
        static let Host = "api.yelp.com"
        static let SearchPath = "/v3"
    }

    // Methods
    struct Methods {
        static let OAuth = "/oauth2/token"
        static let AutoComplete = "/autocomplete"
        static let Search = "/businesses/search"
    }

    // Parameter Keys
    struct ParameterKeys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"

        // Autocomplete
        static let Text = "text"

        // Search
        static let Term = "term"
        static let Categories = "categories"

        // OAuth
        static let GrantType = "grant_type"
        static let ClientId = "client_id"
        static let ClientSecret = "client_secret"
    }

    // Parameter Values
    struct ParameterValues {
        static let GrantType = "client_credentials"
    }

    // GET CALLS
    func getAutocompleteSuggestions(searchText: String, latitude: Double, longitude: Double, completionHandlerForAutocomplete: @escaping (_ suggestions: AutocompleteSuggestion?, _ error: Error?) -> Void) {

        let parameters: [String :Any] = [ParameterKeys.Text: searchText,
                                         ParameterKeys.Latitude: latitude,
                                         ParameterKeys.Longitude: longitude]

        _ = getMethod(parameters: parameters, path: Constants.SearchPath, pathExtension: Methods.AutoComplete) { result, error in

            guard error == nil,
                let dictionary = result,
                let formattedTerms = dictionary["terms"] as? [[String: String]],
                let formattedCategories = dictionary["categories"] as? [[String: String]],
                let formattedBusinesses = dictionary["businesses"] as? [[String: String]] else {
                    // TODO: flush this out more
                    completionHandlerForAutocomplete(nil, .inApp)
                    return
            }

            var suggestions = AutocompleteSuggestion()

            for term in formattedTerms {
                if let termToAdd = term["text"] {
                    suggestions.terms.append(termToAdd)
                }
            }

            for category in formattedCategories {
//                var categoryExists = false
//
//                if let alias = category["alias"] {
//                    let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
//                    categoryFetch.predicate = NSPredicate(format: "alias = %@", argumentArray: [alias])
//
//                    do {
//                        let existingCategories = try self.stack.context.fetch(categoryFetch)
//                        if let firstCategory = existingCategories.first {
//                            suggestions.categories.append(firstCategory)
//                            categoryExists = true
//                        }
//                    } catch {
//                        #if DEBUG
//                            print("There was a problem fetching categories for autocomplete: \(error)")
//                        #endif
//                    }
//                }
//
//                if !categoryExists {
                    let newCategory = Category(dictionary: category, context: self.stack.context)
                    suggestions.categories.append(newCategory)
//                }
            }

            for business in formattedBusinesses {
//                if let id = business["id"] {
//                    let businessFetch: NSFetchRequest<Business> = Business.fetchRequest()
//                    businessFetch.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
//
//                    do {
//                        let existingBusinesses = try self.stack.context.fetch(businessFetch)
//                        if let firstBusiness = existingBusinesses.first {
//                            suggestions.businesses.append(firstBusiness)
//                        }
//                    } catch {
//                        #if DEBUG
//                            print("There was a problem fetching businesses for autocomplete: \(error)")
//                        #endif
//                    }
//                } else {
                    let newBusiness = Business(dictionary: business, status: .search, context: self.stack.context)
                    suggestions.businesses.append(newBusiness)
//                }
            }
            completionHandlerForAutocomplete(suggestions, nil)
        }
    }

    func search(byTerm term: String?, byCategory category: String?, latitude: Double, longitude: Double, completionHandlerForSearch: @escaping (_ success: Bool, _ error: Error?) -> Void) {

        var parameters: [String: Any] = [ParameterKeys.Latitude: latitude,
                                         ParameterKeys.Longitude: longitude]

        if let term = term {
            parameters[ParameterKeys.Term] = term
        } else if let category = category {
            parameters[ParameterKeys.Categories] = category
        }

        _ = getMethod(parameters: parameters, path: Constants.SearchPath, pathExtension: Methods.Search) { result, error in
            guard error == nil,
                let dictionary = result,
                let businesses = dictionary["businesses"] as? [[String: Any]] else {
                    // TODO: flush this out more
                    completionHandlerForSearch(false, .inApp)
                    return
            }

            //var businessesToReturn = [Business]()

            for business in businesses {
            if let id = business["id"] {
                let businessFetch: NSFetchRequest<Business> = Business.fetchRequest()
                businessFetch.predicate = NSPredicate(format: "id = %@", argumentArray: [id])

                do {
                    let existingBusinesses = try self.stack.context.fetch(businessFetch)
                    if let firstBusiness = existingBusinesses.first {
                        //businessesToReturn.append(firstBusiness)
                    } else {
                        let newBusiness = Business(dictionary: business, status: .search, context: self.stack.context)
                    }
                } catch {
                    #if DEBUG
                        print("There was a problem fetching businesses for autocomplete: \(error)")
                    #endif
                }
            } else {
                let newBusiness = Business(dictionary: business, status: .search, context: self.stack.context)
                }



//                let newBusiness = NSEntityDescription.insertNewObject(forEntityName: "Business", into: self.stack.context) as! Business
//                newBusiness.setProperties(dictionary: business, status: .search, context: self.stack.context)
//
//                do {
//                    try self.stack.context.save()
//                } catch {
//                    if error.code == 133021 {
//
//                    } else {
//                        print(error)
//                    }
//                }
               // businessesToReturn.append(newBusiness)
//            }
        }
            completionHandlerForSearch(true, nil)
    }
    }

    // GET Method
    func getMethod(parameters: [String: Any], path: String, pathExtension: String, completionHandlerForGet: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {

        guard let url = urlFromComponents(scheme: Constants.Scheme, host: Constants.Host, path: path, withPathExtension: pathExtension, parameters: parameters) else {
            #if DEBUG
                print("There was a problem creating the url to get autocomplete suggesions")
            #endif
            completionHandlerForGet(nil, .inApp)
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token.getTokenId())", forHTTPHeaderField: "Authorization")

        _ = taskForHTTPMethod(request: request) { result, error in
            guard error == nil,
                let data = result else {
                    // TODO: flush this out more
                    completionHandlerForGet(nil, .inApp)
                    return
            }

            self.deserializeJSONWithCompletionHandler(data: data) { result, error in
                guard error == nil,
                    let dictionary = result as? [String: Any] else {
                        // TODO: Flush this out more
                        completionHandlerForGet(nil, .inApp)
                        return
                }
                completionHandlerForGet(dictionary, nil)
            }
        }
    }

    // POST Calls
    func getToken(completionHandlerForGetToken: @escaping (_ success: Bool, _ error: Error?) -> Void) {

        guard let url = urlFromComponents(scheme: Constants.Scheme, host: Constants.Host, path: Methods.OAuth, withPathExtension: nil, parameters: nil) else {
            #if DEBUG
                print("There was a problem creating the url to get the token")
            #endif
            completionHandlerForGetToken(false, .inApp)
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        let bodyString = "\(ParameterKeys.GrantType)=\(ParameterValues.GrantType)&\(ParameterKeys.ClientId)=\(Constants.AppId)&\(ParameterKeys.ClientSecret)=\(Constants.AppSecret)"
        let bodyData = bodyString.data(using: String.Encoding.ascii, allowLossyConversion: true)!

        request.httpBody = bodyData

        _ = taskForHTTPMethod(request: request) { result, error in
            guard error == nil,
                let data = result else {
                    // TODO: flush this out more
                    completionHandlerForGetToken(false, .inApp)
                    return
            }

            self.deserializeJSONWithCompletionHandler(data: data) { result, error in
                guard error == nil,
                    let dictionary = result as? [String: Any],
                    let token = dictionary["access_token"] as? String,
                    let expirationSeconds = dictionary["expires_in"] as? Double else {
                        // TODO: flush this out more
                        completionHandlerForGetToken(false, .inApp)
                        return
                }

                let expirationDate = Date(timeIntervalSinceNow: expirationSeconds)
                
                let sharedToken = YelpToken.sharedInstance
                sharedToken.set(newToken: token, newExpirationDate: expirationDate)
                print(YelpToken.sharedInstance.getTokenId)
                completionHandlerForGetToken(true, nil)
            }
        }
    }
}
