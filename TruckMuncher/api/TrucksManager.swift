//
//  TrucksManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

class TrucksManager {
    let apiManager: APIManager
    
    init() {
        apiManager = APIManager()
    }
    
    func getActiveTrucks(latitude lat: Double, longitude lon: Double, searchQuery search: String) -> [RTruck] {
        let builder = ActiveTrucksRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        builder.searchQuery = search
        apiManager.post(url: "/getActiveTrucks", data: builder.build().getNSData())
        return [RTruck]()
    }
    
    func getTrucksForVendor() -> [RTruck] {
        // TODO if not logged in as vendor, don't even make this request
        let builder = TrucksForVendorRequest.builder()
        apiManager.post(url: "/getTrucksForVendor", data: builder.build().getNSData())
        return [RTruck]()
    }
    
    func getTruckProfiles(latitude lat: Double, longitude lon: Double) -> [RTruck] {
        // TODO returned cached copy instead of network request
        let builder = TruckProfilesRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        apiManager.post(url: "/getTruckProfiles", data: builder.build().getNSData())
        return [RTruck]()
    }
    
    func modifyServingMode(#truckId: String, #isInServingMode: Bool, latitude lat: Double, longitude lon: Double) {
        let builder = ServingModeRequest.builder()
        builder.truckId = truckId
        builder.isInServingMode = isInServingMode
        builder.truckLatitude = lat
        builder.truckLongitude = lon
        apiManager.post(url: "/modifyServingMode", data: builder.build().getNSData())
    }
}
