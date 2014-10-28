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
    
    func getMenuItemAvailability(latitude lat: Double, longitude lon: Double) -> [RMenuItem] {
        let builder = MenuItemAvailabilityRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        apiManager.post(url: "/getMenuItemAvailability", data: builder.build().getNSData())
        return [RMenuItem]()
    }
    
    func getFullMenus(latitude lat: Double, longitude lon: Double, includeAvailability avail: Bool) -> [RMenu] {
        // TODO this should only be run once per time period (TBD) this is our update cache route
        let builder = FullMenusRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        builder.includeAvailability = avail
        apiManager.post(url: "/getFullMenus", data: builder.build().getNSData())
        return [RMenu]()
    }
    
    func getMenu(#truckId: String) -> RMenu {
        // TODO return cached copy instead of network request
        let builder = MenuRequest.builder()
        builder.truckId = truckId
        apiManager.post(url: "/getMenu", data: builder.build().getNSData())
        return RMenu()
    }
    
    func modifyMenuItemAvailability(menuItems items: [String: Bool]) {
        let builder = ModifyMenuItemAvailabilityRequest.builder()
        var diffs = [MenuItemAvailability]()
        for (id, avail) in items {
            let itemBuilder = MenuItemAvailability.builder()
            itemBuilder.menuItemId = id
            itemBuilder.isAvailable = avail
            diffs.append(itemBuilder.build())
        }
        builder.diff = diffs
        apiManager.post(url: "/modifyMenuItemAvailability", data: builder.build().getNSData())
    }
}
