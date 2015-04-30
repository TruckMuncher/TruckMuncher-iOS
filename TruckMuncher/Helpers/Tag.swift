//
//  Tag.swift
//  TruckMuncher
//
//  Created by Josh Ault on 4/29/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import Foundation

enum Tag: String {
    case Gluten = "\u{e004}"
    case Vegetarian = "\u{e000}"
    case Vegan = "\u{e001}"
    case Peanuts = "\u{e002}"
    case Raw = "\u{e003}"
    
    static func initFromString(string: String) -> Tag? {
        switch string {
        case "gluten free":
            return .Gluten
        case "vegetarian":
            return .Vegetarian
        case "vegan":
            return .Vegan
        case "contains peanuts":
            return .Peanuts
        case "raw":
            return .Raw
        default:
            return nil
        }
    }
}
