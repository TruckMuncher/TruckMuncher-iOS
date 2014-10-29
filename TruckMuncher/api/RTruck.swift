//
//  RTruck.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RTruck: RLMObject {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var imageUrl = ""
    dynamic var keywords = [String]()
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var isNew = false
    
    init(_ truck: ActiveTrucksResponse.Truck) {
        id = truck.id
        latitude = truck.latitude
        longitude = truck.longitude
        super.init()
    }
    
    init(_ truck: Truck, isNew: Bool) {
        id = truck.id
        name = truck.name
        imageUrl = truck.imageUrl
        keywords = truck.keywords
        self.isNew = isNew
        super.init()
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
