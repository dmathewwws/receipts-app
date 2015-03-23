//
//  Receipts.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-03-21.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import Foundation
import CoreData

@objc(Receipts)

class Receipts: NSManagedObject {

    @NSManaged var amount: NSDecimalNumber
    @NSManaged var modifiedDate: NSDate
    @NSManaged var note: String
    @NSManaged var labels: NSSet

}
