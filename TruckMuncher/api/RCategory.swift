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
    
    override init() {
        super.init()
    }
    
    class func initFromProto(category: [String: AnyObject]) -> RCategory {
        let rcategory = RCategory()
        rcategory.id = category["id"] as! String
        rcategory.name = category["name"] as! String
        rcategory.notes = category["notes"] as! String
        rcategory.orderInMenu = category["orderInMenu"] as! Int
        for menuItem in category["menuItems"] as! [[String: AnyObject]] {
            rcategory.menuItems.addObject(RMenuItem.initFromFullProto(menuItem))
        }
        return rcategory
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
