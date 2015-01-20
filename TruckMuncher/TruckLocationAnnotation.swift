//
//  VendorLocationAnnotation.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit

class TruckLocationAnnotation: NSObject, MKAnnotation {
    
    let coordinate : CLLocationCoordinate2D
    var index : Int
    var title : String!
    var subtitle : String!
    var truckId: String!
    
    init(location coord:CLLocationCoordinate2D, index:Int, truckId: String!) {
        self.coordinate = coord
        self.index = index
        self.truckId = truckId
        super.init()
    }
}