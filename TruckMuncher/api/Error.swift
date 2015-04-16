//
//  Error.swift
//  TruckMuncher
//
//  Created by Josh Ault on 4/16/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import Foundation

class Error {
    var userMessage: String = ""
    var internalCode: String = ""
    
    class func parseFromDict(dict: [String: AnyObject]) -> Error {
        let error = Error()
        error.userMessage = dict["userMessage"] as! String
        error.internalCode = dict["internalCode"] as! String
        return error
    }
}