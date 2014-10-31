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

    func post(request: URLRequestConvertible, success successBlock: (response: NSHTTPURLResponse?, data: NSData?) -> (), error errorBlock: (response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> ()) {
        
        manager.request(request)
            .validate()
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                
                let nsdata = data as? NSData
                if error == nil {
                    println("successful request")
                    successBlock(response: response, data: nsdata)
                } else {
                    println("failed request")
                    errorBlock(response: response, data: nsdata, error: error)
                }
        }
    }
}

enum APIRouter: URLRequestConvertible {
    static let baseUrl = "https://api.truckmuncher.com:8443"
    
    case getActiveTrucks(NSData)
    case getTrucksForVendor(NSData)
    case getTruckProfiles(NSData)
    case modifyServingMode(NSData)
    
    case getMenuItemAvailability(NSData)
    case getFullMenus(NSData)
    case getMenu(NSData)
    case modifyMenuItemAvailability(NSData)
    
    case getAuth(NSData)
    case deleteAuth(NSData)
    
    var properties: (path: String, parameters: NSData) {
        switch self {
        case .getActiveTrucks(let data):
            return ("/com.truckmuncher.api.trucks.TruckService/getActiveTrucks", data)
        case .getTrucksForVendor(let data):
            return ("/com.truckmuncher.api.trucks.TruckService/getTrucksForVendor", data)
        case .getTruckProfiles(let data):
            return ("/com.truckmuncher.api.trucks.TruckService/getTruckProfiles", data)
        case .modifyServingMode(let data):
            return ("/com.truckmuncher.api.trucks.TruckService/modifyServingMode", data)
        case .getMenuItemAvailability(let data):
            return ("/com.truckmuncher.api.menu.MenuService/getMenuItemAvailability", data)
        case .getFullMenus(let data):
            return ("/com.truckmuncher.api.menu.MenuService/getFullMenus", data)
        case .getMenu(let data):
            return ("/com.truckmuncher.api.menu.MenuService/getMenu", data)
        case .modifyMenuItemAvailability(let data):
            return ("/com.truckmuncher.api.menu.MenuService/modifyMenuItemAvailability", data)
        case .getAuth(let data):
            return ("/com.truckmuncher.api.auth.AuthService/getAuth", data)
        case .deleteAuth(let data):
            return ("/com.truckmuncher.api.auth.AuthService/deleteAuth", data)
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: APIRouter.baseUrl)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(properties.path))
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let sessionToken = NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String
        println("found token \(sessionToken)")
        if let st = sessionToken {
            println("found val \(st)")
            mutableURLRequest.setValue("session_token=\(st)", forHTTPHeaderField: "Authorization")
            let val = mutableURLRequest.valueForHTTPHeaderField("Authorization")
        }
        mutableURLRequest.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/x-protobuf", forHTTPHeaderField: "Accept")
        mutableURLRequest.setValue("\(NonceUtils.generateNonce())", forHTTPHeaderField: "X-Nonce")
        mutableURLRequest.setValue("\(TimestampUtils.generateTimestamp())", forHTTPHeaderField: "X-Timestamp")
        mutableURLRequest.HTTPBody = properties.parameters
        return mutableURLRequest
    }
}

struct NonceUtils {
    static func generateNonce() -> String {
        let length = 32
        let data = NSMutableData(length: length)!
        let result = SecRandomCopyBytes(kSecRandomDefault, UInt(length), UnsafeMutablePointer<UInt8>(data.mutableBytes))
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
