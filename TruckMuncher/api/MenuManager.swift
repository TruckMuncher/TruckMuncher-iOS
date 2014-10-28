//
//  MenuManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

struct MenuManager {
    let apiManager: APIManager

    init() {
        apiManager = APIManager()
    }
    
    func getMenuItemAvailability(atLatitude lat: Double, longitude lon: Double) -> [RMenuItem] {
        let builder = MenuItemAvailabilityRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        apiManager.post(APIRouter.getMenuItemAvailability(builder.build().getNSData()), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
        return [RMenuItem]()
    }
    
    func getFullMenus(atLatitude lat: Double, longitude lon: Double, includeAvailability avail: Bool) -> [RMenu] {
        // TODO this should only be run once per time period (TBD). this is our update cache route
        let builder = FullMenusRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        builder.includeAvailability = avail
        apiManager.post(APIRouter.getFullMenus(builder.build().getNSData()), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
        return [RMenu]()
    }
    
    func getMenu(#truckId: String) -> RMenu {
        let results = RMenu.objectsWhere("truckId = %@", truckId)
        if results.count == 0 {
            // get from network
            let builder = MenuRequest.builder()
            builder.truckId = truckId
            apiManager.post(APIRouter.getMenu(builder.build().getNSData()), success: { (response, data) -> () in
                // success
            }) { (response, data, error) -> () in
                // error
            }
            // TODO persist results in realm and return
            return RMenu()
        } else {
            return results.firstObject() as RMenu
        }
    }
    
    func modifyMenuItemAvailability(#items: [String: Bool]) {
        let builder = ModifyMenuItemAvailabilityRequest.builder()
        var diffs = [MenuItemAvailability]()
        for (id, avail) in items {
            let itemBuilder = MenuItemAvailability.builder()
            itemBuilder.menuItemId = id
            itemBuilder.isAvailable = avail
            diffs.append(itemBuilder.build())
        }
        builder.diff = diffs
        apiManager.post(APIRouter.modifyMenuItemAvailability(builder.build().getNSData()), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
    }
}
