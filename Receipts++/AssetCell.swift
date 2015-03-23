//
//  AssetCellCollectionViewCell.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-03-18.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit

class AssetCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aCheckMark: CheckMark!
    
    var reuseCount: Int = 0
    
    override var selected: Bool {
        didSet {
            aCheckMark.hidden = !selected
        }
    }
    
}
