//
//  AuthManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/28/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire
import Realm

struct AuthManager {
    let apiManager: APIManager
    
    init() {
        apiManager = APIManager()
    }
    
    func signIn(authorization auth: String, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        
        let request = APIRouter.getAuth([String: AnyObject]()).URLRequest as! NSMutableURLRequest
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        apiManager.post(request as NSURLRequest, success: { (response, dict) -> () in
            // success
            let ruser = RUser.initFromProto(dict!)
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
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
    
    func signOut(success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
        apiManager.post(APIRouter.deleteAuth([String: AnyObject]()), success: { (response, dict) -> () in
            // success
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            realm.deleteObjects(RUser.allObjectsInRealm(realm))
            realm.commitWriteTransaction()
            
            successBlock()
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
