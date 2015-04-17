//
//  RUser.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/28/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RUser: RLMObject {
    dynamic var id = ""
    dynamic var username = ""
    dynamic var sessionToken = ""
    dynamic var truckIds = RLMArray(objectClassName: RString.className())
    
    class func initFromProto(auth: [String: AnyObject]) -> RUser {
        let ruser = RUser()
        ruser.id = auth["userId"] as! String
        ruser.username = auth["username"] as! String
        ruser.sessionToken = auth["sessionToken"] as! String
        return ruser
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
