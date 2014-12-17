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
        let builder = SimpleSearchRequest.builder()
        builder.query = query
        builder.limit = Int32(limit)
        builder.offset = Int32(offset)
        apiManager.post(APIRouter.simpleSearch(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            var searchResponse = SimpleSearchResponse.parseFromNSData(data!)
            var responses = [RSearch]()
            for response in searchResponse.searchResponse {
                responses.append(RSearch.initFromProto(response))
            }
            successBlock(response: responses)
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
