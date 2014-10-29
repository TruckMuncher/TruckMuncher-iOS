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
            .validate(statusCode: [200])
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                println("data \(data)")
                println("error \(error)")
                
                let nsdata = data as? NSData
                if error == nil {
                    successBlock(response: response, data: nsdata)
                } else {
                    errorBlock(response: response, data: nsdata, error: error)
                }
        }
    }
}

enum APIRouter: URLRequestConvertible {
    static let baseUrl = "http://10.0.1.5:8443"
    
    case getActiveTrucks(NSData)
    case getTrucksForVendor(NSData)
    case getTruckProfiles(NSData)
    case modifyServingMode(NSData)
    
    case getMenuItemAvailability(NSData)
    case getFullMenus(NSData)
    case getMenu(NSData)
    case modifyMenuItemAvailability(NSData)
    
    case signIn()
    case signOut()
    
    var properties: (path: String, parameters: NSData?) {
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
        case .signIn():
            return ("/auth", nil)
        case .signOut():
            return ("/auth", nil)
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: APIRouter.baseUrl)
        let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(properties.path))
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let sessionToken = NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as String
        mutableURLRequest.setValue("session_token=\(sessionToken)", forHTTPHeaderField: "Authorization")
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
        let components = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: NSDate())
        return "\(components.year)-\(components.month)-\(components.day)T\(components.hour):\(components.minute):\(components.second)Z"
    }
}
