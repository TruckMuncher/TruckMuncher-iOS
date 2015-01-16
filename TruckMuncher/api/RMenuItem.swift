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
    //dynamic var tags = [String]()
    dynamic var tags = RLMArray(objectClassName: RString.className())
    dynamic var orderInCategory = 0
    dynamic var isAvailable = true
    
    override init() {
        super.init()
    }
    
    class func initFromProto(menuItem: MenuItemAvailability) -> RMenuItem {
        let rmenuitem = RMenuItem()
        rmenuitem.id = menuItem.menuItemId
        rmenuitem.isAvailable = menuItem.isAvailable
        return rmenuitem
    }
    
    class func initFromProto(menuItem: MenuItem) -> RMenuItem {
        let rmenuitem = RMenuItem()
        rmenuitem.id = menuItem.id
        rmenuitem.name = menuItem.name
        rmenuitem.price = Double(menuItem.price)
        rmenuitem.notes = menuItem.notes
        //rmenuitem.tags = menuItem.tags
        for tag in menuItem.tags {
            rmenuitem.tags.addObject(RString.initFromString(tag))
        }
        rmenuitem.orderInCategory = Int(menuItem.orderInCategory)
        rmenuitem.isAvailable = menuItem.isAvailable
        return rmenuitem
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
