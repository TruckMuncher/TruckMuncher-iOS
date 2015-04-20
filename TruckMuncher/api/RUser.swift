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
    dynamic var fbUsername = ""
    dynamic var twUsername = ""
    dynamic var hasFb = false // realm doesnt support optionals, so we cant check if fbUsername is nil, need this flag
    dynamic var hasTw = false
    dynamic var postToFb = false
    dynamic var postToTw = false
    dynamic var sessionToken = ""
    dynamic var truckIds = RLMArray(objectClassName: RString.className())
    dynamic var favorites = RLMArray(objectClassName: RString.className())
    
    class func initFromProto(auth: [String: AnyObject]) -> RUser {
        let ruser = RUser()
        ruser.id = auth["userId"] as! String
        ruser.sessionToken = auth["sessionToken"] as! String
        if let user = auth["user"] as? [String: AnyObject] {
            ruser.id = user["id"] as! String
            let fbUsername = user["fbUsername"] as? String
            let twUsername = user["twUsername"] as? String
            ruser.fbUsername = fbUsername ?? ""
            ruser.twUsername = twUsername ?? ""
            ruser.hasFb = fbUsername != nil
            ruser.hasTw = twUsername != nil
            ruser.postToFb = user["postToFb"] as? Bool ?? false
            ruser.postToTw = user["postToTw"] as? Bool ?? false
        }
        return ruser
    }
    
    override class func primaryKey() -> String! {
        return "id"
    }
}
