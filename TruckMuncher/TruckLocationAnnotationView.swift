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
        let image = UIImage(named:"LocationSetterPin")
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        self.centerOffset = CGPointMake(0,-20)
        self.opaque = false
        annotationImage = UIImage(named:"LocationSetterPin")
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        annotationImage.drawInRect(self.bounds.rectByInsetting(dx: 5, dy: 5))
    }
}
