//
//  CheckMark.swift
//  MultipleAssetPicker
//
//  Created by Daniel Mathews on 2015-03-14.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit
import CoreGraphics

class CheckMark: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        drawRectChecked()
    }
    
    func drawRectChecked() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let checkmarkBlue2 = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        //// Shadow Declarations
        let shadow2 = UIColor.blackColor()
        let shadow2Offset = CGSize(width: 0.1, height: -0.1)
        let shadow2BlurRadius = 2.5
        
        //// Frames
        let frame = bounds
        
        //// Subframes
        let group = CGRect(x: CGRectGetMinX(frame) + 3, y: CGRectGetMinY(frame) + 3, width: CGRectGetWidth(frame) - 6, height: CGRectGetHeight(frame) - 6)
        
        //// CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(ovalInRect:CGRect(x: CGRectGetMinX(group) + 0.5, y: CGRectGetMinY(group) + 0.5, width: CGRectGetWidth(group) + 1, height: CGRectGetHeight(group) + 1))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow2Offset, CGFloat(shadow2BlurRadius), shadow2.CGColor)
        checkmarkBlue2.setFill()
        checkedOvalPath.fill()
        CGContextRestoreGState(context)
        
        UIColor.whiteColor().setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), y: CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPoint(x: CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), y: CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group)))
        bezierPath.addLineToPoint(CGPoint(x: CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), y: CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group)))
        bezierPath.lineCapStyle = kCGLineCapSquare
        
        UIColor.whiteColor().setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
}
