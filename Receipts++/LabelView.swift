//
//  LabelView.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-04-04.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import Photos

class LabelView: UIView {
    @IBOutlet weak var noteTextView: UITextView!
    
//    var asset: PHAsset? {
//        didSet {
//            noteTextView.text = asset?.description ?? "No Title"
//        }
//    }
    
    var receipt: Receipts? {
        didSet {
            noteTextView.text = receipt?.note
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
//    override func alignmentRectForFrame(frame: CGRect) -> CGRect {
//        return bounds
//    }

}
