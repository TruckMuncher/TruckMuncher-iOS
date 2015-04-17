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
    dynamic var keywords = RLMArray(objectClassName: RString.className())
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var isNew = false
    dynamic var isInServingMode = false
    dynamic var primaryColor = "#FFFFFF"
    dynamic var secondaryColor = "#000000"
    dynamic var distanceFromMe = 0.0
    dynamic var approved = false
    dynamic var approvalPending = false
    
    override init() {
        super.init()
    }
    
    class func initFromProto(truck: [String: AnyObject]) -> RTruck {
        let rtruck = RTruck()
        rtruck.id = truck["id"] as! String
        rtruck.latitude = truck["latitude"] as? Double ?? 0.0
        rtruck.longitude = truck["longitude"] as? Double ?? 0.0
        return rtruck
    }
    
    class func initFromProto(truck: [String: AnyObject], isNew: Bool) -> RTruck {
        let rtruck = RTruck()
        rtruck.id = truck["id"] as! String
        rtruck.name = truck["name"] as? String ?? ""
        rtruck.imageUrl = truck["imageUrl"] as? String ?? ""
        if let keywords = truck["keywords"] as? [String] {
            for keyword in keywords {
                rtruck.keywords.addObject(RString.initFromString(keyword))
            }
        }
        rtruck.isNew = isNew
        rtruck.primaryColor = truck["primaryColor"] as? String ?? ""
        rtruck.secondaryColor = truck["secondaryColor"] as? String ?? ""
        rtruck.approved = truck["approved"] as? Bool ?? false
        rtruck.approvalPending = truck["approvalPending"] as? Bool ?? false
        return rtruck
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
    
    override class func ignoredProperties() -> [AnyObject]! {
        return ["distanceFromMe"]
    }
}
