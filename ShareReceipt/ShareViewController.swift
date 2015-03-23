//
//  ShareViewController.swift
//  ShareReceipt
//
//  Created by Daniel Mathews on 2015-03-18.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import Social
import CoreData

class ShareViewController: SLComposeServiceViewController {

    var managedObjectContext = ReceiptsCoreDataManager.sharedInstance.managedObjectContext
    
    override func isContentValid() -> Bool {
        
        if let currentMessage = contentText{
            println("currentMessage in isContentValid \(currentMessage)")
        }

        
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    func loadDataHome() {
        
        let receiptEntity = NSEntityDescription.entityForName("Receipts", inManagedObjectContext: managedObjectContext!)!
        let newManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(receiptEntity.name!, inManagedObjectContext: managedObjectContext!) as Receipts
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        newManagedObject1.amount = NSDecimalNumber(double: 0.99)
        newManagedObject1.note = "Extensions!!"
        newManagedObject1.modifiedDate = NSDate()
        
        
        let labelEntity = NSEntityDescription.entityForName("Labels", inManagedObjectContext: managedObjectContext!)!
        let labelManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(labelEntity.name!, inManagedObjectContext: managedObjectContext!) as Labels
        
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        labelManagedObject1.label = "Extension"
        
        newManagedObject1.labels = NSSet(object: labelManagedObject1)
        
        // Save the context.
        
        ReceiptsCoreDataManager.sharedInstance.saveContext(){ success in
            println("in saveContext w/ success = \(success)")
        }
        
        
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        if let currentMessage = contentText{
            println("currentMessage in didSelectPost \(currentMessage)")
        }
        
        //loadDataHome()
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
