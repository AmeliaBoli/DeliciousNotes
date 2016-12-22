//
//  YelpService.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/20/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation
import CoreData

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
        static let Businesses = "/businesses"
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

    // Helper Methods
    func saveBusiness(dictionary: [String: Any]) -> Business? {
        if let id = dictionary["id"] {
            let businessFetch: NSFetchRequest<Business> = Business.fetchRequest()
            businessFetch.predicate = NSPredicate(format: "id = %@", argumentArray: [id])

            var businessToReturn: Business? = nil
        //    stack.context.perform {
                do {
                    let existingBusinesses = try self.stack.context.fetch(businessFetch)
                    if let firstBusiness = existingBusinesses.first {
                        if firstBusiness.update(dictionary: dictionary, context: self.stack.context) {
                            businessToReturn = firstBusiness
                        } else {
                            #if DEBUG
                                print("There was a problem updating existing business: \(firstBusiness) with properties \(dictionary)")
                            #endif
                        }
                    } else {
                        if let newBusiness = Business(dictionary: dictionary, status: .search, context: self.stack.context) {
                            businessToReturn = newBusiness
                        } else {
                            #if DEBUG
                                print("A business could not be completed with \(dictionary)")
                            #endif
                        }
                    }
                } catch {
                    #if DEBUG
                        print("There was a problem fetching businesses for autocomplete: \(error)")
                    #endif
                }
          //  }
            return businessToReturn
        } else {
            #if DEBUG
                print("There was no id in \(dictionary)")
            #endif
            return nil
        }
    }

    // GET CALLS
    func getAutocompleteSuggestions(searchText: String, latitude: Double, longitude: Double, completionHandlerForAutocomplete: @escaping (_ suggestions: [[String: Any]]?, _ error: ErrorType?) -> Void) {

        let parameters: [String :Any] = [ParameterKeys.Text: searchText,
                                         ParameterKeys.Latitude: latitude,
                                         ParameterKeys.Longitude: longitude]

        _ = getMethod(parameters: parameters, path: Constants.SearchPath, pathExtension: Methods.AutoComplete) { result, error in

            guard error == nil else {
                completionHandlerForAutocomplete(nil, error!)
                return
            }

            guard let dictionary = result,
                let formattedTerms = dictionary["terms"] as? [[String: String]],
                let formattedCategories = dictionary["categories"] as? [[String: String]],
                let formattedBusinesses = dictionary["businesses"] as? [[String: String]] else {
                    completionHandlerForAutocomplete(nil, .malformedJson)
                    return
            }

            var suggestions = [[String: Any]]()

            for term in formattedTerms {
                if let termToAdd = term["text"] {
                    suggestions.append(["term": termToAdd])
                }
            }

            for category in formattedCategories {

                if let alias = category["alias"],
                    let title = category["title"] {

                    if YelpCategory(rawValue: title) != nil {
                        suggestions.append(["alias": alias, "title": title])
                    }
                }
            }

            for business in formattedBusinesses {
                if let businessName = business["name"] {
                    suggestions.append(["business": businessName])
                }
            }

            completionHandlerForAutocomplete(suggestions, nil)
        }
    }

    func search(byTerm term: String?, byCategory category: String?, latitude: Double, longitude: Double, completionHandlerForSearch: @escaping (_ businesses: [Business]?, _ error: ErrorType?) -> Void) {

        var parameters: [String: Any] = [ParameterKeys.Latitude: latitude,
                                         ParameterKeys.Longitude: longitude]

        if let term = term {
            parameters[ParameterKeys.Term] = term
        } else if let category = category {
            parameters[ParameterKeys.Categories] = category
        }

        _ = getMethod(parameters: parameters, path: Constants.SearchPath, pathExtension: Methods.Search) { result, error in
            guard error == nil else {
                completionHandlerForSearch(nil, error)
                return
            }

            guard let dictionary = result,
                let businesses = dictionary["businesses"] as? [[String: Any]] else {
                    completionHandlerForSearch(nil, .malformedJson)
                    return
            }

            var businessesToReturn = [Business]()

            for business in businesses {
                if let newBusiness = self.saveBusiness(dictionary: business) {
                    businessesToReturn.append(newBusiness)
                }

            }
            completionHandlerForSearch(businessesToReturn, nil)
        }
    }

    func getBusiness(businessId: String, completionHandlerForGetBusiness: @escaping (_ success: Bool, _ error: ErrorType?) -> Void) {

        let pathExtension = Methods.Businesses + "/" + businessId
        _ = getMethod(parameters: [:], path: Constants.SearchPath, pathExtension: pathExtension) { result, error in
            guard error == nil else {
                completionHandlerForGetBusiness(false, error)
                return
            }

            guard let businessDictionary = result else {
                    completionHandlerForGetBusiness(false, .malformedJson)
                    return
            }

            if let _ = self.saveBusiness(dictionary: businessDictionary) {
                completionHandlerForGetBusiness(true, nil)
            } else {
                completionHandlerForGetBusiness(false, .storage)
            }
        }
    }

    // GET Method
    func getMethod(parameters: [String: Any], path: String, pathExtension: String, completionHandlerForGet: @escaping (_ result: [String: Any]?, _ error: ErrorType?) -> Void) {

        guard let url = urlFromComponents(scheme: Constants.Scheme, host: Constants.Host, path: path, withPathExtension: pathExtension, parameters: parameters) else {
            #if DEBUG
                print("There was a problem creating the url to get autocomplete suggesions")
            #endif
            completionHandlerForGet(nil, .inApp)
            return
        }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token.getTokenId())", forHTTPHeaderField: "Authorization")

        _ = taskForHTTPMethod(request: request) { result, error in
            guard error == nil else {
                completionHandlerForGet(nil, error)
                return
            }

            guard let data = result else {
                completionHandlerForGet(nil, .inApp)
                return
            }

            self.deserializeJSONWithCompletionHandler(data: data) { result, error in
                guard error == nil,
                    let dictionary = result as? [String: Any] else {
                        completionHandlerForGet(nil, .jsonSerialization)
                        return
                }
                completionHandlerForGet(dictionary, nil)
            }
        }
    }

    // POST Calls
    func getToken(completionHandlerForGetToken: @escaping (_ success: Bool, _ error: ErrorType?) -> Void) {

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
            guard error == nil else {
                completionHandlerForGetToken(false, error)
                return
            }

            guard let data = result else {
                completionHandlerForGetToken(false, .inApp)
                return
            }

            self.deserializeJSONWithCompletionHandler(data: data) { result, error in
                guard error == nil,
                    let dictionary = result as? [String: Any],
                    let token = dictionary["access_token"] as? String,
                    let expirationSeconds = dictionary["expires_in"] as? Double else {
                        completionHandlerForGetToken(false, .jsonSerialization)
                        return
                }

                let expirationDate = Date(timeIntervalSinceNow: expirationSeconds)
                
                let sharedToken = YelpToken.sharedInstance
                sharedToken.set(newToken: token, newExpirationDate: expirationDate)
                completionHandlerForGetToken(true, nil)
            }
        }
    }
}
