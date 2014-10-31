//
//  AuthManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/28/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire

struct AuthManager {
    let apiManager: APIManager
    
    init() {
        apiManager = APIManager()
    }
    
    func signIn(authorization auth: String, success successBlock: (response: RUser) -> (), error errorBlock: (error: Error?) -> ()) {
        let builder = AuthRequest.builder()
        
        let request = APIRouter.getAuth(builder.build().getNSData()).URLRequest as NSMutableURLRequest
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        apiManager.post(request as NSURLRequest, success: { (response, data) -> () in
            // success
            var authResponse = AuthResponse.parseFromNSData(data!)
            successBlock(response: RUser.initFromProto(authResponse))
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(nsdata)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func signOut(success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
        let builder = AuthRequest.builder()
        apiManager.post(APIRouter.deleteAuth(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            successBlock()
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(nsdata)
            }
            errorBlock(error: errorResponse)
        }
    }
}
