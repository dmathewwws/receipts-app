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

class AddLabelViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var selectedAssets = [PHAsset]()
    let manager = PHImageManager.defaultManager()
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = selectedAssets.count
        pageControl.currentPage = 0
        
        
        for eachAsset:PHAsset in selectedAssets{
            scrollView.contentSize.height += CGFloat(eachAsset.pixelHeight)
            scrollView.contentSize.width += CGFloat(eachAsset.pixelWidth)
        }
        
//        loadFirstImage(selectedAssets[0] as PHAsset)
        
        let firstImage = selectedAssets[0] as PHAsset
        
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        manager.requestImageForAsset(firstImage, targetSize: CGSizeMake(CGFloat(firstImage.pixelWidth), CGFloat(firstImage.pixelHeight)), contentMode: PHImageContentMode.AspectFill, options: options )
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
        
        //println("location for firstAsset is \(firstImage.location)");
        
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func labelButtonPressed(sender: AnyObject) {
        
    }
    
}
