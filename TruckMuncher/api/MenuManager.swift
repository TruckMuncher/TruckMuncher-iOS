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
    
    func getMenuItemAvailability(atLatitude lat: Double, longitude lon: Double, success successBlock: (response: [RMenuItem]) -> (), error errorBlock: (error: Error?) -> ()) {
        let builder = MenuItemAvailabilityRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        apiManager.post(APIRouter.getMenuItemAvailability(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            var menuItemResponse = MenuItemAvailabilityResponse.parseFromNSData(data!)
            var items = [RMenuItem]()
            for item in menuItemResponse.availabilities {
                items.append(RMenuItem(item))
            }
            successBlock(response: items)
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(data!)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getFullMenus(atLatitude lat: Double, longitude lon: Double, includeAvailability avail: Bool, success successBlock: (response: [RMenu]) -> (), error errorBlock: (error: Error?) -> ()) {
        // TODO this should only be run once per time period (TBD). this is our update cache route
        let builder = FullMenusRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        builder.includeAvailability = avail
        apiManager.post(APIRouter.getFullMenus(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            var menuResponse = FullMenusResponse.parseFromNSData(data!)
            var menus = [RMenu]()
            for menu in menuResponse.menus {
                menus.append(RMenu(menu))
            }
            successBlock(response: menus)
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(data!)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getMenu(#truckId: String, success successBlock: (response: RMenu) -> (), error errorBlock: (error: Error?) -> ()) {
        let builder = MenuRequest.builder()
        builder.truckId = truckId
        apiManager.post(APIRouter.getMenu(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            // TODO persist results in realm and return
            var menuResponse = MenuResponse.parseFromNSData(data!)
            successBlock(response: RMenu(menuResponse.menu))
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(data!)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func modifyMenuItemAvailability(#items: [String: Bool], success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
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
