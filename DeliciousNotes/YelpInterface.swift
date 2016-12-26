//
//  YelpInterface.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import Foundation

class YelpInterface {

    static let sharedInstance = YelpInterface()
    private init() { }

    let token = YelpToken.sharedInstance
    let yelpService = YelpService.sharedInstance

    func fetchAutocompleteSuggesions(searchText: String, latitude: Double, longitude: Double, completionHandlerForAutocomplete: @escaping ([[String: Any]]?, ErrorType?) -> Void) {
        if token.isValid() {
            yelpService.getAutocompleteSuggestions(searchText: searchText, latitude: latitude, longitude: longitude) { result, error in
                guard error == nil,
                    let suggestions = result else {
                        #if DEBUG
                            print("There was a problem with getting the suggesions: \(error)")
                        #endif
                        completionHandlerForAutocomplete(nil, error)
                        return
                }
                completionHandlerForAutocomplete(suggestions, nil)
            }
        } else {
            yelpService.getToken() { success, error in
                guard success,
                    error == nil else {
                    #if DEBUG
                        print("There was a problem retrieving the token: \(error)")
                    #endif
                    completionHandlerForAutocomplete(nil, error)
                    return
                }
                self.yelpService.getAutocompleteSuggestions(searchText: searchText, latitude: latitude, longitude: longitude) { result, error in
                    guard error == nil,
                        let suggestions = result else {
                            #if DEBUG
                                print("There was a problem with getting the suggestions: \(error)")
                            #endif
                            completionHandlerForAutocomplete(nil, error)
                            return
                    }
                    completionHandlerForAutocomplete(suggestions, nil)
                }
            }
        }
    }

    func fetchSearchResults(term: String?, category: String?, latitude: Double, longitude: Double, completionHandlerForAutocomplete: @escaping (_ businesses: [TemporaryBusiness]?, _ error: ErrorType?) -> Void) {
        if token.isValid() {
            yelpService.search(byTerm: term, byCategory: category, latitude: latitude, longitude: longitude) { result, error in
                guard error == nil,
                    let businesses = result else {
                        #if DEBUG
                            print("There was a problem with getting the suggesions: \(error)")
                        #endif
                        completionHandlerForAutocomplete(nil, error)
                        return
                }
                completionHandlerForAutocomplete(businesses, nil)
            }
        } else {
            yelpService.getToken() { success, error in
                guard success,
                    error == nil else {
                        #if DEBUG
                            print("There was a problem retrieving the token: \(error)")
                        #endif
                        completionHandlerForAutocomplete(nil, error)
                        return
                }
                self.yelpService.search(byTerm: term, byCategory: category, latitude: latitude, longitude: longitude) { result, error in
                    guard error == nil,
                        let businesses = result else {
                            #if DEBUG
                                print("There was a problem with getting the suggestions: \(error)")
                            #endif
                            completionHandlerForAutocomplete(nil, error)
                            return
                    }
                    completionHandlerForAutocomplete(businesses, nil)
                }
            }
        }
    }

    func fetchBusiness(businessId: String, completionHandlerForBusiness: @escaping ( _ success: Bool, _ error: ErrorType?) -> Void) {
        if token.isValid() {
            yelpService.getBusiness(businessId: businessId) { success, error in
                    guard error == nil,
                    success else {
                        #if DEBUG
                            print("There was a problem with getting the business \(businessId): \(error)")
                        #endif
                        completionHandlerForBusiness(false, error)
                        return
                }
                completionHandlerForBusiness(true, nil)
            }
        } else {
            yelpService.getToken() { success, error in
                guard success,
                    error == nil else {
                        #if DEBUG
                            print("There was a problem retrieving the token: \(error)")
                        #endif
                        completionHandlerForBusiness(false, error)
                        return
                }
                self.yelpService.getBusiness(businessId: businessId) { success, error in
                    guard error == nil,
                        success else {
                            #if DEBUG
                                print("There was a problem with getting the business \(businessId): \(error)")
                            #endif
                            completionHandlerForBusiness(false, error)
                            return
                    }
                    completionHandlerForBusiness(true, nil)
                }
            }
        }
    }
}
