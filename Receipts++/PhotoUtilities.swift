//
//  PhotoUtilities.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-03-24.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import Photos

class PhotoUtilities: NSObject {
   
    let myAlbumName = "Receipts++"
    var assetCollectionPlaceholder: PHObjectPlaceholder!

    class var sharedInstance: PhotoUtilities {
        struct Static {
            static var instance: PhotoUtilities?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PhotoUtilities()
        }
        
        return Static.instance!
    }
    
    func createAlbum(completionClosure:(assetCollection: PHAssetCollection?) ->())
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", myAlbumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let first_obj: AnyObject = collection.firstObject {
            completionClosure(assetCollection: collection.firstObject as! PHAssetCollection?)
        } else {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                var createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.myAlbumName)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    if (success) {
                        var collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        print(collectionFetchResult, appendNewline: false)
                        completionClosure(assetCollection: collectionFetchResult.firstObject as! PHAssetCollection?)
                    }
            })
        }
    }
}
