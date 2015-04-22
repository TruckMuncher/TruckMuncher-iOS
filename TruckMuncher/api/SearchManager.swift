//
//  TrucksManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

class SearchManager {
    let apiManager: APIManager
    
    init() {
        apiManager = APIManager()
    }
    
    func simpleSearch(#query: String, withLimit limit: Int, andOffset offset: Int, success successBlock: (response: [RSearch]) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["query"] = query
        dict["limit"] = limit
        dict["offset"] = offset
        apiManager.post(APIRouter.simpleSearch(dict), retry: false, success: { (response, dict) -> () in
            // success
            var responses = [RSearch]()
            for response in dict!["searchResponse"] as! [[String: AnyObject]] {
                responses.append(RSearch.initFromProto(response))
            }
            successBlock(response: responses)
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
