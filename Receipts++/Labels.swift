//
//  Labels.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-03-21.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import Foundation
import CoreData

@objc(Labels)

class Labels: NSManagedObject {

    @NSManaged var label: String
    @NSManaged var isLocation: NSNumber
    @NSManaged var isCategory: NSNumber
    @NSManaged var receipts: NSSet

}
