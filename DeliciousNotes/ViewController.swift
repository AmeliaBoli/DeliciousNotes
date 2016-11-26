//
//  ViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/20/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Business> = Business.fetchRequest()

        do {
            let businesses = try StackSingleton.sharedInstance.stack!.context.fetch(fetchRequest)
            print("$$$$$$$$$$")
            for business in businesses {
                print(business.id! as String)
            }
        } catch {
            print("Fetch failed: \(error)")
        }

        YelpService.sharedInstance.getToken() { success in
            YelpService.sharedInstance.getAutocompleteSuggestions(searchText: "deli", latitude: 37.7, longitude: -122.3) { result, error in
                let firstTerm = result!.categories.first!.alias
                YelpService.sharedInstance.search(byTerm: nil, byCategory: firstTerm!, latitude: 37.7, longitude: -122.3) { success, error in
                    guard error == nil else {
                        print(error!.rawValue)
                        return
                    }

                    do {
                        let businesses = try StackSingleton.sharedInstance.stack!.context.fetch(fetchRequest)
                        print("$$$$$$$$$$\(businesses)")
                    } catch {
                        print("Fetch failed: \(error)")
                    }
                }
            }
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

