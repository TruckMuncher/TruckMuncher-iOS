//
//  UserManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 4/19/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class UserManager {
    let apiManager: APIManager
    
    init() {
        apiManager = APIManager()
    }
    
    func getAccount(success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        apiManager.post(APIRouter.getAccount([String: AnyObject]()), success: { (response, dict) -> () in
            // success
            let ruser = RUser.objectsWhere("sessionToken = %@", (NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String) ?? "").firstObject() as! RUser
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            let fbUsername = dict!["fbUsername"] as? String
            let twUsername = dict!["twUsername"] as? String
            ruser.fbUsername = fbUsername ?? ""
            ruser.twUsername = twUsername ?? ""
            ruser.hasFb = fbUsername != nil
            ruser.hasTw = twUsername != nil
            ruser.postToFb = dict!["postToFb"] as? Bool ?? false
            ruser.postToTw = dict!["postToTw"] as? Bool ?? false
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: ruser)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func modifyAccount(postToFb: Bool?, postToTw: Bool?, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["postToFb"] = postToFb ?? NSNull()
        dict["postToTw"] = postToTw ?? NSNull()
        apiManager.post(APIRouter.modifyAccount(dict), success: { (response, dict) -> () in
            // success
            let ruser = RUser.objectsWhere("sessionToken = %@", (NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String) ?? "").firstObject() as! RUser
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            let fbUsername = dict!["fbUsername"] as? String
            let twUsername = dict!["twUsername"] as? String
            ruser.fbUsername = fbUsername ?? ""
            ruser.twUsername = twUsername ?? ""
            ruser.hasFb = fbUsername != nil
            ruser.hasTw = twUsername != nil
            ruser.postToFb = dict!["postToFb"] as? Bool ?? false
            ruser.postToTw = dict!["postToTw"] as? Bool ?? false
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: ruser)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func linkFacebookAccount(accessToken: String, postActivity: Bool, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        #if DEBUG
            linkAccount("access_token=fb\(accessToken)|TestUserFb", postActivity: postActivity, success: successBlock, error: errorBlock)
        #elseif RELEASE
            linkAccount("access_token=\(accessToken)", postActivity: postActivity, success: successBlock, error: errorBlock)
        #endif
    }
    
    func linkTwitterAccount(authToken: String, secretToken: String, postActivity: Bool, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        #if DEBUG
            linkAccount("oauth_token=tw\(authToken), oauth_secret=TestUserTw", postActivity: postActivity, success: successBlock, error: errorBlock)
        #elseif RELEASE
            linkAccount("oauth_token=\(authToken), oauth_secret=\(secretToken)", postActivity: postActivity, success: successBlock, error: errorBlock)
        #endif
    }
    
    func linkAccount(authHeader: String, postActivity: Bool, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["postActivity"] = postActivity
        
        let request = APIRouter.linkAccount(dict).URLRequest as! NSMutableURLRequest
        let currentAuthHeader = request.valueForHTTPHeaderField("Authorization")
        request.setValue("\(currentAuthHeader!), \(authHeader)", forHTTPHeaderField: "Authorization")
        
        apiManager.post(request as NSURLRequest, success: { (response, dict) -> () in
            // success
            let ruser = RUser.objectsWhere("sessionToken = %@", (NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String) ?? "").firstObject() as! RUser
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            let fbUsername = dict!["fbUsername"] as? String
            let twUsername = dict!["twUsername"] as? String
            ruser.fbUsername = fbUsername ?? ""
            ruser.twUsername = twUsername ?? ""
            ruser.hasFb = fbUsername != nil
            ruser.hasTw = twUsername != nil
            ruser.postToFb = dict!["postToFb"] as? Bool ?? false
            ruser.postToTw = dict!["postToTw"] as? Bool ?? false
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: ruser)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func unlinkAccount(unlinkFacebook fb: Bool?, unlinkTwitter tw: Bool?, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["facebook"] = fb ?? NSNull()
        dict["twitter"] = tw ?? NSNull()
        apiManager.post(APIRouter.unlinkAccount(dict), success: { (response, dict) -> () in
            // success
            let ruser = RUser.objectsWhere("sessionToken = %@", (NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String) ?? "").firstObject() as! RUser
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            let fbUsername = dict!["fbUsername"] as? String
            let twUsername = dict!["twUsername"] as? String
            ruser.fbUsername = fbUsername ?? ""
            ruser.twUsername = twUsername ?? ""
            ruser.hasFb = fbUsername != nil
            ruser.hasTw = twUsername != nil
            ruser.postToFb = dict!["postToFb"] as? Bool ?? false
            ruser.postToTw = dict!["postToTw"] as? Bool ?? false
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: ruser)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getFavorites(success successBlock: (response: [RString]) -> (), error errorBlock: (error: Error?) -> ()) {
        apiManager.post(APIRouter.getFavorites([String: AnyObject]()), success: { (response, dict) -> () in
            //success
            var favorites = [RString]()
            
            let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as! String).firstObject() as! RUser
            ruser.favorites.removeAllObjects()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for favorite in dict!["favorites"] as! [String] {
                let rfavorite = RString.initFromString(favorite)
                ruser.favorites.addObject(rfavorite)
            }
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: favorites)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func addFavorite(favorite: String, success successBlock: (response: [RString]) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["truckId"] = favorite
        apiManager.post(APIRouter.addFavorite(dict), success: { (response, dict) -> () in
            //success
            var favorites = [RString]()
            
            let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as! String).firstObject() as! RUser
            ruser.favorites.removeAllObjects()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for favorite in dict!["favorites"] as! [String] {
                let rfavorite = RString.initFromString(favorite)
                ruser.favorites.addObject(rfavorite)
            }
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: favorites)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func removeFavorite(favorite: String, success successBlock: (response: [RString]) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["truckId"] = favorite
        apiManager.post(APIRouter.removeFavorite(dict), success: { (response, dict) -> () in
            //success
            var favorites = [RString]()
            
            let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as! String).firstObject() as! RUser
            ruser.favorites.removeAllObjects()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for favorite in dict!["favorites"] as! [String] {
                let rfavorite = RString.initFromString(favorite)
                ruser.favorites.addObject(rfavorite)
            }
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: favorites)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
}
