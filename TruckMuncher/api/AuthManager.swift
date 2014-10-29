//
//  AuthManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/28/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

struct AuthManager {
    let apiManager: APIManager
    
    init() {
        apiManager = APIManager()
    }
    
    func signIn(authorization auth: String, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        apiManager.post(APIRouter.signIn(), success: { (response, data) -> () in
            // success
            var authResponse = AuthResponse.parseFromNSData(data!)
            successBlock(response: RUser(authResponse))
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(data!)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func signOut(success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
        apiManager.post(APIRouter.signOut(), success: { (response, data) -> () in
            // success
            successBlock()
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(data!)
            }
            errorBlock(error: errorResponse)
        }
    }
}
