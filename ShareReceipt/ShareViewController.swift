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
import MobileCoreServices
import Photos
import CoreLocation

class ShareViewController: SLComposeServiceViewController {

    var managedObjectContext = ReceiptsCoreDataManager.sharedInstance.managedObjectContext
    
    override func viewDidLoad() {
        // 1
        let items = extensionContext?.inputItems
        var itemProvider: NSItemProvider?
        
        // 2
        if items != nil && items!.isEmpty == false {
            let item = items![0] as NSExtensionItem
            if let attachments = item.attachments {
                if !attachments.isEmpty {
                    // 3
                    itemProvider = attachments[0] as? NSItemProvider
                }
            }
        }
        
        // 4
        let imageType = kUTTypeImage as NSString as String
        if itemProvider?.hasItemConformingToTypeIdentifier(imageType) == true
        {
            // 5
            itemProvider?.loadItemForTypeIdentifier(imageType,
                options: nil)
                { item, error in
                    if error == nil {
                        // 6
                        let url = item as NSURL
                        if let imageData = NSData(contentsOfURL: url) {
                            
                            //let firstImage = self.PHAssetForFileURL(url)
                            
                            println("url for image is \(url)");
                            //println("localIdentifier for firstAsset is \(firstImage!.localIdentifier)");
                            
                        }
                    } else {
                        // 7
                        let title = "Unable to load image"
                        let message = "Please try again or choose a different image."
                        
                        let alert = UIAlertController(title: title,
                            message: message,
                            preferredStyle: .Alert)
                        
                        let action = UIAlertAction(title: "Bummer",
                            style: .Cancel)
                            { _ in
                                self.dismissViewControllerAnimated(true,
                                    completion: nil)
                        }
                        
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true,
                            completion: nil)
                    }
            }
        }
    }
    
    func PHAssetForFileURL(url: NSURL) -> PHAsset? {
        var imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.version = .Current
        imageRequestOptions.deliveryMode = .FastFormat
        imageRequestOptions.resizeMode = .Fast
        imageRequestOptions.synchronous = true
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsWithOptions(options)
        for var index = 0; index < fetchResult.count; index++ {
            if let asset = fetchResult[index] as? PHAsset {
                var found = false
                PHImageManager.defaultManager().requestImageDataForAsset(asset,
                    options: imageRequestOptions) { (_, _, _, info) in
                        if let urlkey = info["PHImageFileURLKey"] as? NSURL {
                            if urlkey.absoluteString! == url.absoluteString! {
                                found = true
                            }
                        }
                }
                if (found) {
                    return asset
                }
            }
        }
    
        return nil
    }
    
    override func isContentValid() -> Bool {
        
        if let currentMessage = contentText{
            println("currentMessage in isContentValid \(currentMessage)")
        }

        
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    /*func loadDataHome() {
        
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
        
        
    }*/

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        extensionContext?.inputItems
        
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
