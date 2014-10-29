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
    
    init(_ menu: Menu) {
        truckId = menu.truckId
        for category in menu.categories {
            categories.addObject(RCategory(category))
        }
        super.init()
    }
    
    override class func primaryKey() -> String! {
        return "truckId"
    }
}
