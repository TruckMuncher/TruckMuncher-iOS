//
//  RTruck.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class RSearch: RLMObject {
    dynamic var blurb = ""
    dynamic var truck = RTruck()
    dynamic var menu = RMenu()
    
    override init() {
        super.init()
    }
    
    class func initFromProto(searchResponse: SearchResponse) -> RSearch {
        let rsearch = RSearch()
        rsearch.blurb = searchResponse.blurb
        rsearch.truck = RTruck.initFromProto(searchResponse.truck, isNew: false)
        rsearch.menu = RMenu.initFromProto(searchResponse.menu)
        return rsearch
    }
}
