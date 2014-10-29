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
    
    init(_ auth: AuthResponse) {
        id = auth.id
        username = auth.username
        sessionToken = auth.sessionToken
        super.init()
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
