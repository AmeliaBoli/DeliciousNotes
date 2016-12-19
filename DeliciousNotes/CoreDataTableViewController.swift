//
//  CoreDataTableView.swift
//  DeliciousNotes
//
//  Created by Amelia Boli on 12/10/16.
//  Copyright © 2016 Appogenic. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CoreDataTableView: UITableView

class CoreDataTableView: UITableView {

    // MARK: Properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            self.reloadData()
        }
    }

    // MARK: Initializers

    init(fetchedResultsController fc: NSFetchedResultsController<NSFetchRequestResult>, frame: CGRect, style: UITableViewStyle = .plain) {
        fetchedResultsController = fc
        super.init(frame: frame, style: style)
    }

    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - CoreDataTableView (Fetches)

extension CoreDataTableView {

    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

// MARK: - CoreDataTableView: NSFetchedResultsControllerDelegate

extension CoreDataTableView: NSFetchedResultsControllerDelegate{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let set = IndexSet(integer: sectionIndex)

        switch (type) {
        case .insert:
            self.insertSections(set, with: .fade)
        case .delete:
            self.deleteSections(set, with: .fade)
        default:
            // irrelevant in our case
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch(type) {

        case .insert:
            self.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.deleteRows(at: [indexPath!], with: .fade)
            self.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.endUpdates()
    }
}
