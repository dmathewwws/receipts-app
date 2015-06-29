//
//  AddLabelViewController.swift
//  MultipleAssetPicker
//
//  Created by Daniel Mathews on 2015-03-16.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import CoreData

class AddLabelViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var showLabelView: UIButton!
    @IBOutlet weak var nextOrDoneButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var selectedAssets = [PHAsset]()
    let manager = PHImageManager.defaultManager()
    
    var imageView: UIImageView!
    var labelView: LabelView!
    var receipt: Receipts!
    var currentIndex:Int = 0
    
    private let kLabelViewHeight: CGFloat = 400
    private let kLabelViewWidth: CGFloat  = 300
    
    var managedObjectContext = ReceiptsCoreDataManager.sharedInstance.managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedAssets.count > 1 {
            pageControl.numberOfPages = selectedAssets.count
            pageControl.currentPage = 0
        } else {
            pageControl.removeFromSuperview()
            nextOrDoneButton.setTitle("Done", forState: UIControlState.Normal)
        }
        
        //Initalize without previous button.
        previousButton.hidden = true

//        for eachAsset:PHAsset in selectedAssets{
//            scrollView.contentSize.height += CGFloat(eachAsset.pixelHeight)
//            scrollView.contentSize.width += CGFloat(eachAsset.pixelWidth)
//        }
        
        loadImageAtIndex(currentIndex)
        
        //println("location for firstAsset is \(firstImage.location)");
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        /*FoursquareManager.sharedInstance.getVenuesFromLocation(firstImage.location) { data in
            if let getsResponses = data["response"] as [NSObject:AnyObject]?{
                if let venueResponses = getsResponses["venues"] as [[NSObject:AnyObject]]?{
                    if let firstVenue = venueResponses[0] as [NSObject:AnyObject]?{
                        let name = firstVenue["name"] as String
                        println("firstVenue's name is \(name)")
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //self.priceLabel.text = amount //+ "   " + currency
                        })
                        
                    }
                }
            }
        }*/
    }
    
    func createNewReceiptForAsset(asset:PHAsset) -> Receipts {
        
        let fetchRequest = NSFetchRequest()
        let predicate = NSPredicate(format: "assetLocalIdentifier = %@", asset.localIdentifier)
        
        let receiptEntity = NSEntityDescription.entityForName("Receipts", inManagedObjectContext: managedObjectContext!)!
        fetchRequest.entity = receiptEntity
        fetchRequest.predicate = predicate
        
        receipt = Receipts(asset: asset, entity: receiptEntity, insertIntoManagedObjectContext:managedObjectContext!)
        
        if let receipts = ReceiptsCoreDataManager.sharedInstance.executeFetchRequest(fetchRequest) {
            if let coreDataReceipt: Receipts = receipts[0] as? Receipts {
                receipt = coreDataReceipt
                
            }
        }
        
        let labelEntity = NSEntityDescription.entityForName("Labels", inManagedObjectContext: managedObjectContext!)!
        let labelManagedObject1 = NSEntityDescription.insertNewObjectForEntityForName(labelEntity.name!, inManagedObjectContext: managedObjectContext!) as! Labels

        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        labelManagedObject1.label = "Work"

        receipt.labels = NSSet(object: labelManagedObject1)
        
        return receipt
    }
    
    func loadImageAtIndex(index:Int){
        
        let asset = selectedAssets[index] as PHAsset!
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        
        receipt = createNewReceiptForAsset(asset)
        
        manager.requestImageForAsset(asset, targetSize: CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight)), contentMode: PHImageContentMode.AspectFill, options: options )
            { result, info in
                self.imageView = UIImageView(image: result)
                self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: result.size)
                self.scrollView.contentSize = result.size
                self.scrollView.addSubview(self.imageView)
                
                let scrollViewFrame = self.scrollView.frame
                let scaleWidth = Double(scrollViewFrame.size.width) / Double(self.scrollView.contentSize.width)
                let scaleHeigth = Double(scrollViewFrame.size.height) / Double(self.scrollView.contentSize.height)
                let minScale = min(CGFloat(scaleWidth), CGFloat(scaleHeigth))
                let maxScale = max(CGFloat(scaleWidth), CGFloat(scaleHeigth))
                self.scrollView.minimumZoomScale = minScale
                
                self.scrollView.maximumZoomScale = 1.0
                self.scrollView.zoomScale = maxScale
                
                self.centerScrollViewContents()
        }
    }
    
    func centerScrollViewContents() {
        
        let boundsSize = scrollView.bounds.size
        var imageViewFrame = imageView.frame
        
        let screenScale = 1.0
        
        if imageViewFrame.size.width < boundsSize.width {
            imageViewFrame.origin.x  = CGFloat(Double(boundsSize.width - imageViewFrame.size.width) / Double(2.0 * screenScale))
        } else {
            imageViewFrame.origin.x = 0.0
        }
        
        if imageViewFrame.size.height < boundsSize.height {
            imageViewFrame.origin.y  = CGFloat(Double(boundsSize.height - imageViewFrame.size.height)/Double(2.0 * screenScale))
        } else {
            imageViewFrame.origin.y = 0.0
        }
        
        imageView.frame = imageViewFrame
        
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        
        let pointInView = recognizer.locationInView(imageView)
        
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoonTo = CGRectMake(x, y, w, h)
        
        scrollView.zoomToRect(rectToZoonTo, animated: true)
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        centerScrollViewContents()
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        currentIndex++
        if receipt != nil {
            saveDatainLabelViewForReceipt()
        }
        
        if (currentIndex == selectedAssets.count) {
            //Done
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            //Next
            imageView.removeFromSuperview()
            pageControl.currentPage = currentIndex
            previousButton.hidden = false
            loadImageAtIndex(currentIndex)
            
            if (currentIndex == selectedAssets.count-1) {
                nextOrDoneButton.setTitle("Done", forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func labelButtonPressed(sender: AnyObject) {
        if let tipView = createLabelViewForAsset(selectedAssets[currentIndex]) {
            let center = CGPoint(x: CGRectGetWidth(view.bounds)/2, y: CGRectGetHeight(view.bounds)/2)
            tipView.center = center
            view.addSubview(tipView)
        }
    }
    
    @IBAction func previousButtonPressed(sender: AnyObject) {
        
        currentIndex--
        if (currentIndex == 0) {
            //Right Before first Page
            previousButton.hidden = true
        }else if (currentIndex == selectedAssets.count-2) {
            nextOrDoneButton.setTitle(">", forState: UIControlState.Normal)
        }
        //Next
        imageView.removeFromSuperview()
        pageControl.currentPage = currentIndex
        loadImageAtIndex(currentIndex)
    }
    
    func createLabelViewForAsset(asset:PHAsset) -> LabelView? {
        if let view = UINib(nibName: "LabelView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! LabelView? {
            view.frame = CGRect(x: 0, y: 0, width: kLabelViewWidth, height: kLabelViewHeight)
            view.receipt = receipt
            labelView = view
            return labelView
        }
        return nil
    }
    
    func saveDatainLabelViewForReceipt(){
        ReceiptsCoreDataManager.sharedInstance.saveContext(){ success in
            print("in saveContext w/ success = \(success)")
            self.receipt = nil
        }
    }
    
}
