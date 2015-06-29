//
//  ReceiptsTableViewController.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-03-19.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import CoreData

class ReceiptsTableViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var managedObjectContext = ReceiptsCoreDataManager.sharedInstance.managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //loadDataHome()
        //loadDataWork()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        let managedObjectContext = self.managedObjectContext!

        let fetchRequest = NSFetchRequest()

        let entity = NSEntityDescription.entityForName("Labels", inManagedObjectContext:managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "label", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        /* NSFetchedResultsController initialization
        a `nil` `sectionNameKeyPath` generates a single section */
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "label", cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController
        
        // perform initial model fetch
        var e: NSError?
        do {
            try self._fetchedResultsController!.performFetch()
        } catch var error as NSError {
            e = error
            print("fetch error: \(e!.localizedDescription)")
            abort();
        }
        
        return self._fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController?
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! ReceiptsTableViewCell!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ReceiptsTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: ReceiptsTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        
        let receiptsDescSet = object.valueForKeyPath("Receipts") as! NSSet
        for receiptsDesc in receiptsDescSet {
            if let receipt = receiptsDesc as? Receipts {
                cell.receiptNote!.text = receipt.note
                cell.receiptAmount.text = receipt.amount.stringValue
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        //return [sectionInfo title];
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    func loadDataHome() {
        
        let receiptEntity = NSEntityDescription.entityForName("Receipts", inManagedObjectContext: managedObjectContext!)!
        let newManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(receiptEntity.name!, inManagedObjectContext: managedObjectContext!) as! Receipts
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        newManagedObject1.amount = NSDecimalNumber(double: 10.99)
        newManagedObject1.note = "Headphones"
        newManagedObject1.addedToAppDate = NSDate()

        let labelEntity = NSEntityDescription.entityForName("Labels", inManagedObjectContext: managedObjectContext!)!
        let labelManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(labelEntity.name!, inManagedObjectContext: managedObjectContext!) as! Labels
        
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        labelManagedObject1.label = "Home"
        
        newManagedObject1.labels = NSSet(object: labelManagedObject1)
        
        // Save the context.

        ReceiptsCoreDataManager.sharedInstance.saveContext(){ success in
            print("in saveContext w/ success = \(success)")
        }
    }
    
    func loadDataWork() {
        
        let receiptEntity = NSEntityDescription.entityForName("Receipts", inManagedObjectContext: managedObjectContext!)!
        let newManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(receiptEntity.name!, inManagedObjectContext: managedObjectContext!) as! Receipts
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        newManagedObject1.amount = NSDecimalNumber(double: 5.99)
        newManagedObject1.note = "HootSuite Pro"
        newManagedObject1.addedToAppDate = NSDate()
        
        let labelEntity = NSEntityDescription.entityForName("Labels", inManagedObjectContext: managedObjectContext!)!
        let labelManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(labelEntity.name!, inManagedObjectContext: managedObjectContext!) as! Labels

        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        labelManagedObject1.label = "Work"
        
        let labelManagedObject2 = NSEntityDescription.insertNewObjectForEntityForName(labelEntity.name!, inManagedObjectContext: managedObjectContext!) as! Labels
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        labelManagedObject2.label = "Home"
        
        newManagedObject1.labels = NSSet(objects: labelManagedObject1,labelManagedObject2)
        
        ReceiptsCoreDataManager.sharedInstance.saveContext(){ success in
            print("in saveContext w/ success = \(success)")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
