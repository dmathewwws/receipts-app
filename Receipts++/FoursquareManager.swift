//
//  FoursquareManager.swift
//  MultipleAssetPicker
//
//  Created by Daniel Mathews on 2015-03-17.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import Foundation
import CoreLocation

class FoursquareManager: NSObject {
    
    let foursquareClientID = "Y1D1BAQRXK3JDFAOOBWFFCLV5ZJRLISH3KBY1NKHB0WM4GK1"
    let foursquareClientSecret = "S5QSIBLRK44ZFXP3BEYCAYKCDO2GVUUNEMZ3VGIVLZQR1QRW"
    let foursquareLimit = "5"
    
    class var sharedInstance: FoursquareManager {
        struct Static {
            static var instance: FoursquareManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FoursquareManager()
        }
        
        return Static.instance!
    }
    
    func getVenuesFromLocation(location:CLLocation, completionClosure:(dict: [NSObject:AnyObject]) ->()){
        
        let url: NSURL = NSURL(string: "https://api.foursquare.com/v2/venues/search?ll=\(Double(location.coordinate.latitude)),\(Double(location.coordinate.longitude))&limit=\(foursquareLimit)&client_id=\(foursquareClientID)&client_secret=\(foursquareClientSecret)&v=20151219")!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary!
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            completionClosure(dict:jsonResult)
            
        })
        task.resume()
    }
}
