//
//  VendorLocationAnnotationView.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit

class TruckLocationAnnotationView: MKAnnotationView {
    
    var annotationImage : UIImage!
    var countLabel: UILabel!
    var count: Int = 0 {
        didSet {
            countLabel.text = count > 1 ? String(count) : String()
            setNeedsLayout()
        }
    }
    var isUniqueLocation = false
    
    override init(frame: CGRect) { super.init(frame: frame) }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation:MKAnnotation, reuseIdentifier:String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupLabel()
        count = 1

        backgroundColor = UIColor.clearColor()
    }
    
    func setupLabel() {
        countLabel = UILabel (frame: bounds)
        countLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        countLabel.textAlignment = NSTextAlignment.Center
        countLabel.backgroundColor = UIColor.clearColor()
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 2
        countLabel.numberOfLines = 1
        countLabel.font = UIFont.boldSystemFontOfSize(12.0)
        countLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        addSubview(countLabel)
    }
    
    func setUniqueLocation(isUnique: Bool) {
        isUniqueLocation = isUnique
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        var image: UIImage
        var centerOffset: CGPoint
        var countLabelFrame: CGRect
        
        if isUniqueLocation {
            image = UIImage(named: "SingleTruckAnnotationIcon")!
            centerOffset = CGPointMake(0, image.size.height * 0.5)
            frame = bounds
            frame.origin.y -= 2
            countLabelFrame = frame
        } else {
            var suffix: String
            if count > 50 {
                suffix = "40"
            } else if count > 20 {
                suffix = "35"
            } else if count > 10 {
                suffix = "30"
            } else if count > 5 {
                suffix = "25"
            } else {
                suffix = "20"
            }
            var imageName = "ClusterIcon\(suffix)"
            image = UIImage(named: imageName)!
            
            centerOffset = CGPointZero
            countLabelFrame = bounds
        }
        
        countLabel.frame = countLabelFrame
        self.image = image
        self.centerOffset = centerOffset
    }
}
 