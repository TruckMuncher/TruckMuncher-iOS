//
//  RMenuItem.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RMenuItem: RLMObject {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var price = 0.0
    dynamic var notes = ""
    dynamic var tags = [String]()
    dynamic var orderInCategory = 0
    dynamic var isAvailable = true
    
    init(_ menuItem: MenuItemAvailability) {
        id = menuItem.menuItemId
        isAvailable = menuItem.isAvailable
        super.init()
    }
    
    init(_ menuItem: MenuItem) {
        id = menuItem.id
        name = menuItem.name
        price = Double(menuItem.price)
        notes = menuItem.notes
        tags = menuItem.tags
        orderInCategory = Int(menuItem.orderInCategory)
        isAvailable = menuItem.isAvailable
        super.init()
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
