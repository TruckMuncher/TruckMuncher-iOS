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
    
    override init(annotation:MKAnnotation, reuseIdentifier:String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        annotationImage = UIImage(named:"LocationSetterPin")
        self.frame = CGRectMake(0, 0, annotationImage.size.width, annotationImage.size.height)
        self.centerOffset = CGPointMake(0,-20)
        self.opaque = false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        annotationImage.drawInRect(self.bounds.rectByInsetting(dx: 5, dy: 5))
    }
}
