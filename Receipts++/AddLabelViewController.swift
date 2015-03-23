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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var selectedAssets = [PHAsset]()
    let manager = PHImageManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidthBounds = UIScreen.mainScreen().bounds.size.width
        let screenHeightBounds = UIScreen.mainScreen().bounds.size.height
        
        println("screenWidthBounds is \(screenWidthBounds) screenHeight is \(screenHeightBounds)")
        
        let firstImage = selectedAssets[0] as PHAsset
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        manager.requestImageForAsset(firstImage, targetSize: CGSizeMake(screenWidthBounds, screenHeightBounds), contentMode: PHImageContentMode.AspectFill, options: options )
        { result, info in
            self.imageView.image = result
            self.scrollView.contentSize = result.size
        }
        
        //        println("location for firstAsset is \(firstImage.location)");
        
        FoursquareManager.sharedInstance.getVenuesFromLocation(firstImage.location) { data in
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
        }
        
        
        
        
    }
    
    
}
