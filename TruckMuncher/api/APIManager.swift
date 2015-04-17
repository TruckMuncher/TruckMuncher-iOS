//
//  APIManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire
import Security

class APIManager {
    
    let manager: Alamofire.Manager
    
    init() {
        manager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }

    func post(request: URLRequestConvertible, success successBlock: (response: NSHTTPURLResponse?, dict: [String: AnyObject]?) -> (), error errorBlock: (response: NSHTTPURLResponse?, dict: [String: AnyObject]?, error: NSError?) -> ()) {
        
        manager.request(request)
            .validate()
            .responseJSON(options: .allZeros) { (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                let dict = data as? [String: AnyObject]
                if error == nil {
                    successBlock(response: response, dict: dict)
                } else {
                    errorBlock(response: response, dict: dict, error: error)
                }
        }
    }
}

enum APIRouter: URLRequestConvertible {
    static let baseUrl = BASE_URL
    
    case getActiveTrucks([String: AnyObject])
    case getTrucksForVendor([String: AnyObject])
    case getTruckProfiles([String: AnyObject])
    case modifyServingMode([String: AnyObject])
    
    case getMenuItemAvailability([String: AnyObject])
    case getFullMenus([String: AnyObject])
    case getMenu([String: AnyObject])
    case modifyMenuItemAvailability([String: AnyObject])
    
    case getAuth([String: AnyObject])
    case deleteAuth([String: AnyObject])
    
    case simpleSearch([String: AnyObject])
    
    var properties: (path: String, parameters: [String: AnyObject]) {
        switch self {
        case .getActiveTrucks(let dict):
            return ("/com.truckmuncher.api.trucks.TruckService/getActiveTrucks", dict)
        case .getTrucksForVendor(let dict):
            return ("/com.truckmuncher.api.trucks.TruckService/getTrucksForVendor", dict)
        case .getTruckProfiles(let dict):
            return ("/com.truckmuncher.api.trucks.TruckService/getTruckProfiles", dict)
        case .modifyServingMode(let dict):
            return ("/com.truckmuncher.api.trucks.TruckService/modifyServingMode", dict)
        case .getMenuItemAvailability(let dict):
            return ("/com.truckmuncher.api.menu.MenuService/getMenuItemAvailability", dict)
        case .getFullMenus(let dict):
            return ("/com.truckmuncher.api.menu.MenuService/getFullMenus", dict)
        case .getMenu(let dict):
            return ("/com.truckmuncher.api.menu.MenuService/getMenu", dict)
        case .modifyMenuItemAvailability(let dict):
            return ("/com.truckmuncher.api.menu.MenuService/modifyMenuItemAvailability", dict)
        case .getAuth(let dict):
            return ("/com.truckmuncher.api.auth.AuthService/getAuth", dict)
        case .deleteAuth(let dict):
            return ("/com.truckmuncher.api.auth.AuthService/deleteAuth", dict)
        case .simpleSearch(let dict):
            return ("/com.truckmuncher.api.search.SearchService/simpleSearch", dict)
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: APIRouter.baseUrl)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(properties.path))
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let sessionToken = NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String
        if let st = sessionToken {
            mutableURLRequest.setValue("session_token=\(st)", forHTTPHeaderField: "Authorization")
            let val = mutableURLRequest.valueForHTTPHeaderField("Authorization")
        }
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        mutableURLRequest.setValue("\(NonceUtils.generateNonce())", forHTTPHeaderField: "X-Nonce")
        mutableURLRequest.setValue("\(TimestampUtils.generateTimestamp())", forHTTPHeaderField: "X-Timestamp")
        mutableURLRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(properties.parameters, options: nil, error: nil)
        return mutableURLRequest
    }
}

struct NonceUtils {
    static func generateNonce() -> String {
        let length = 32
        let data = NSMutableData(length: length)!
        let result = SecRandomCopyBytes(kSecRandomDefault, length, UnsafeMutablePointer<UInt8>(data.mutableBytes))
        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}

struct TimestampUtils {
    static func generateTimestamp() -> String {
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        let components = cal.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: NSDate())
        return String(format:"%02d-%02d-%02dT%02d:%02d:%02dZ", components.year, components.month, components.day, components.hour, components.minute, components.second)
    }
}
