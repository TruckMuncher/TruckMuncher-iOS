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
    
    func signIn(authorization auth: String) {
        apiManager.post(APIRouter.signIn(), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
    }
    
    func signOut() {
        apiManager.post(APIRouter.signOut(), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
    }
}
