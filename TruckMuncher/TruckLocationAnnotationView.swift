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
    
    override init(annotation:MKAnnotation, reuseIdentifier:String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let image = UIImage(named:"LocationSetterPin.png")
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        self.centerOffset = CGPointMake(0,-20)
        self.opaque = false
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func drawRect(rect: CGRect) {
        let image = UIImage(named:"LocationSetterPin.png")
        image.drawInRect(self.bounds.rectByInsetting(dx: 5, dy: 5))
    }
}
