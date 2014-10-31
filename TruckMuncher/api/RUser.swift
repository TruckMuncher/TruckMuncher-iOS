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
    
    class func initFromProto(auth: AuthResponse) -> RUser {
        let ruser = RUser()
        ruser.id = auth.userId
        ruser.username = auth.username
        ruser.sessionToken = auth.sessionToken
        return ruser
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
