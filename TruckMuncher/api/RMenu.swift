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
    
    class func initFromProto(menu: Menu) -> RMenu {
        let rmenu = RMenu()
        rmenu.truckId = menu.truckId
        for category in menu.categories {
            rmenu.categories.addObject(RCategory.initFromProto(category))
        }
        return rmenu
    }
    
    override class func primaryKey() -> String! {
        return "truckId"
    }
}
