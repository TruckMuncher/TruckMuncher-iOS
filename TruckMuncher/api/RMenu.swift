//
//  RMenu.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RMenu: RLMObject {
    dynamic var truckId = ""
    dynamic var categories = RLMArray(objectClassName: RCategory.className())
    
    override init() {
        super.init()
    }
    
    class func initFromProto(menu: [String: AnyObject]) -> RMenu {
        let rmenu = RMenu()
        rmenu.truckId = menu["truckId"] as! String
        if let categories = menu["categories"] as? [[String: AnyObject]] {
            for category in categories {
                rmenu.categories.addObject(RCategory.initFromProto(category))
            }
        }
        return rmenu
    }
    
    override class func primaryKey() -> String! {
        return "truckId"
    }
}
