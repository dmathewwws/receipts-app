//
//  Receipts.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-04-08.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import Foundation
import CoreData
import Photos

@objc(Receipts)

class Receipts: NSManagedObject {

    @NSManaged var amount: NSDecimalNumber
    @NSManaged var assetLocalIdentifier: String
    @NSManaged var createdDate: NSDate
    @NSManaged var addedToAppDate: NSDate
    @NSManaged var note: String
    @NSManaged var labels: NSSet
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(asset:PHAsset, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        assetLocalIdentifier = asset.localIdentifier
        note = asset.description
    }
}
