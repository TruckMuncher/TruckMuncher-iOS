//
//  RCategory.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RCategory: RLMObject {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var notes = ""
    dynamic var orderInMenu = 0
    dynamic var menuItems = RLMArray(objectClassName: RMenuItem.className())
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
