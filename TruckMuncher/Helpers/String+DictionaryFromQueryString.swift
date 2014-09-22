//
//  String+dictionaryFromQueryString.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/22/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import Foundation

extension String {
    func queryParams() -> [String: String]! {
        var queryParams = [String: String]()
        for keyValue in self.componentsSeparatedByString("&") {
            let pair = keyValue.componentsSeparatedByString("=")
            queryParams[pair[0]] = pair[1]
        }
        return queryParams
    }
}