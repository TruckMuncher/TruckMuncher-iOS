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

    func post(request: URLRequestConvertible, success: (response: NSHTTPURLResponse?, data: AnyObject?) -> (), error: (response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> ()) {
        
        Alamofire.request(request)
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                println("data \(data)")
                println("error \(error)")
                
                if let nsdata = data as? NSData {
                    var availabilityResponse = ModifyMenuItemAvailabilityResponse.parseFromNSData(nsdata)
                    println("availability response \(availabilityResponse)")
                }
        }
    }
}

enum APIRouter: URLRequestConvertible {
    static let baseUrl = "https://api.truckmuncher.com:8443"
    
    case getActiveTrucks(NSData)
    case getTrucksForVendor()
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
            return ("/getActiveTrucks", data)
        case .getTrucksForVendor():
            return ("/getTrucksForVendor", nil)
        case .getTruckProfiles(let data):
            return ("/getTruckProfiles", data)
        case .modifyServingMode(let data):
            return ("/modifyServingMode", data)
        case .getMenuItemAvailability(let data):
            return ("/getMenuItemAvailability", data)
        case .getFullMenus(let data):
            return ("/getFullMenus", data)
        case .getMenu(let data):
            return ("/getMenu", data)
        case .modifyMenuItemAvailability(let data):
            return ("/modifyMenuItemAvailability", data)
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
        var bytes = [UInt8]()
        SecRandomCopyBytes(kSecRandomDefault, 32, &bytes)
        let data = NSData(bytes: bytes, length: 32)
        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}

struct TimestampUtils {
    static func generateTimestamp() -> String {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: NSDate())
        return "\(components.year)-\(components.month)-\(components.day)T\(components.hour):\(components.minute):\(components.second)Z"
    }
}
