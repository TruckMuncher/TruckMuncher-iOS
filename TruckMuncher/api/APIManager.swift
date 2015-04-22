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
import Realm
import TwitterKit

class APIManager {
    
    let manager: Alamofire.Manager
    
    init() {
        manager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }

    func post(request: URLRequestConvertible, retry: Bool = true, success successBlock: (response: NSHTTPURLResponse?, dict: [String: AnyObject]?) -> (), error errorBlock: (response: NSHTTPURLResponse?, dict: [String: AnyObject]?, error: NSError?) -> ()) {
        
        manager.request(request)
            .validate()
            .responseJSON(options: .allZeros) { (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
                let dict = data as? [String: AnyObject]
                if error == nil {
                    successBlock(response: response, dict: dict)
                } else {
                    let ruser = RUser.objectsWhere("sessionToken = %@", (NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String) ?? "").firstObject() as? RUser ?? nil
                    if let user = ruser where response?.statusCode == 401 && retry {
                        // auto retry any requests (after logging in) that failed because our session was expired
                        var auth = ""
                        if ruser!.hasTw && Twitter.sharedInstance().session() != nil {
                            #if DEBUG
                                auth = "oauth_token=tw985c9758-e11b-4d02-9b39-98aa8d00d429, oauth_secret=munch"
                            #elseif RELEASE
                                auth = "oauth_token=\(Twitter.sharedInstance().session().authToken), oauth_secret=\(Twitter.sharedInstance().session().authTokenSecret)"
                            #endif
                        } else if ruser!.hasFb && FBSDKAccessToken.currentAccessToken() != nil {
                            #if DEBUG
                                auth = "access_token=fb985c9758-e11b-4d02-9b39|FBUser"
                            #elseif RELEASE
                                auth = "access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
                            #endif
                        }
                        
                        let authRequest = APIRouter.getAuth([String: AnyObject]()).URLRequest as! NSMutableURLRequest
                        authRequest.setValue(auth, forHTTPHeaderField: "Authorization")
                        
                        self.post(authRequest as NSURLRequest, retry: false, success: { (authResponse, authDict) -> () in
                            // success
                            let realm = RLMRealm.defaultRealm()
                            realm.beginWriteTransaction()
                            
                            let newruser = RUser.initFromProto(authDict!)
                            ruser!.sessionToken = newruser.sessionToken
                            ruser!.fbUsername = newruser.fbUsername
                            ruser!.twUsername = newruser.twUsername
                            ruser!.hasFb = newruser.hasFb
                            ruser!.hasTw = newruser.hasTw
                            ruser!.postToFb = newruser.postToFb
                            ruser!.postToTw = newruser.postToTw
                            ruser!.sessionToken = newruser.sessionToken
                            
                            realm.addOrUpdateObject(ruser!)
                            realm.commitWriteTransaction()
                            
                            NSUserDefaults.standardUserDefaults().setValue(ruser!.sessionToken, forKey: "sessionToken")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            // retry the original request but signal no more retries
                            //update the request header and send it off
                            (request as! NSMutableURLRequest).setValue("session_token=\(ruser!.sessionToken)", forHTTPHeaderField: "Authorization")
                            
                            self.post(request, retry: false, success: successBlock, error: errorBlock)
                        }) { (authResponse, authDict, authError) -> () in
                            // this auto login attempt should be transparent if it failed
                            // use the original error we got and original errorBlock
                            errorBlock(response: response, dict: dict, error: error)
                        }
                    } else {
                        errorBlock(response: response, dict: dict, error: error)
                    }
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
    
    case getAccount([String: AnyObject])
    case modifyAccount([String: AnyObject])
    case linkAccount([String: AnyObject])
    case unlinkAccount([String: AnyObject])
    case getFavorites([String: AnyObject])
    case addFavorite([String: AnyObject])
    case removeFavorite([String: AnyObject])
    
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
        case .getAccount(let dict):
            return ("/com.truckmuncher.api.user.UserService/getAccount", dict)
        case .modifyAccount(let dict):
            return ("/com.truckmuncher.api.user.UserService/modifyAccount", dict)
        case .linkAccount(let dict):
            return ("/com.truckmuncher.api.user.UserService/linkAccount", dict)
        case .unlinkAccount(let dict):
            return ("/com.truckmuncher.api.user.UserService/unlinkAccounts", dict)
        case .getFavorites(let dict):
            return ("/com.truckmuncher.api.user.UserService/getFavorites", dict)
        case .addFavorite(let dict):
            return ("/com.truckmuncher.api.user.UserService/addFavorite", dict)
        case .removeFavorite(let dict):
            return ("/com.truckmuncher.api.user.UserService/removeFavorite", dict)
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
