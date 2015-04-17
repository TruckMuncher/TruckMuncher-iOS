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
    dynamic var tags = RLMArray(objectClassName: RString.className())
    dynamic var orderInCategory = 0
    dynamic var isAvailable = true
    
    override init() {
        super.init()
    }
    
    class func initFromSmallProto(menuItem: [String: AnyObject]) -> RMenuItem {
        let rmenuitem = RMenuItem()
        rmenuitem.id = menuItem["menuItemId"] as! String
        rmenuitem.isAvailable = menuItem["isAvailable"] as? Bool ?? false
        return rmenuitem
    }
    
    class func initFromFullProto(menuItem: [String: AnyObject]) -> RMenuItem {
        let rmenuitem = RMenuItem()
        rmenuitem.id = menuItem["id"] as! String
        rmenuitem.name = menuItem["name"] as? String ?? ""
        rmenuitem.price = menuItem["price"] as? Double ?? 0.0
        rmenuitem.notes = menuItem["notes"] as? String ?? ""
        if let tags = menuItem["tags"] as? [String] {
            for tag in tags {
                rmenuitem.tags.addObject(RString.initFromString(tag))
            }
        }
        rmenuitem.orderInCategory = menuItem["orderInCategory"] as? Int ?? 0
        rmenuitem.isAvailable = menuItem["isAvailable"] as? Bool ?? false
        return rmenuitem
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
