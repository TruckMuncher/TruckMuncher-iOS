//
//  RString.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/28/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RString: RLMObject {
    dynamic var value = ""
    
    class func initFromString(string: String) -> RString {
        let rstring = RString()
        rstring.value = string
        return rstring
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? RString {
            return value == object.value
        }
        return false
    }
    
    override var hash: Int {
        return value.hashValue
    }
}
