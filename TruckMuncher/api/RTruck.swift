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
    //dynamic var keywords = [String]()
    dynamic var keywords = RLMArray(objectClassName: RString.className())
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var isNew = false
    dynamic var isInServingMode = false
    dynamic var primaryColor = "#FFFFFF"
    dynamic var secondaryColor = "#000000"
    
    override init() {
        super.init()
    }
    
    class func initFromProto(truck: ActiveTrucksResponse.Truck) -> RTruck {
        let rtruck = RTruck()
        rtruck.id = truck.id
        rtruck.latitude = truck.latitude
        rtruck.longitude = truck.longitude
        return rtruck
    }
    
    class func initFromProto(truck: Truck, isNew: Bool) -> RTruck {
        let rtruck = RTruck()
        rtruck.id = truck.id
        rtruck.name = truck.name
        rtruck.imageUrl = truck.imageUrl
        //rtruck.keywords = truck.keywords
        for keyword in truck.keywords {
            rtruck.keywords.addObject(RString.initFromString(keyword))
        }
        rtruck.isNew = isNew
        rtruck.primaryColor = truck.primaryColor
        rtruck.secondaryColor = truck.secondaryColor
        return rtruck
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
