//
//  WishlistViewController.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 11/26/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit

class WishlistViewController: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var restaurantTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func editPressed(_ sender: UIBarButtonItem) {
    }

    @IBAction func filterChanged(_ sender: UISegmentedControl) {
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
