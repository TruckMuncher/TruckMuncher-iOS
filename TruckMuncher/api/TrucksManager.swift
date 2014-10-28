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
    
    func getActiveTrucks(atLatitude lat: Double, longitude lon: Double, withSearchQuery search: String) -> [RTruck] {
        let builder = ActiveTrucksRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        builder.searchQuery = search
        apiManager.post(APIRouter.getActiveTrucks(builder.build().getNSData()), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
        return [RTruck]()
    }
    
    func getTrucksForVendor() -> [RTruck] {
        // TODO if not logged in as vendor, don't even make this request
        let builder = TrucksForVendorRequest.builder()
        apiManager.post(APIRouter.getTrucksForVendor(), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
        return [RTruck]()
    }
    
    func getTruckProfiles(atLatitude lat: Double, longitude lon: Double) -> [RTruck] {
        // TODO returned cached copy instead of network request
        let builder = TruckProfilesRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        apiManager.post(APIRouter.getTruckProfiles(builder.build().getNSData()), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
        return [RTruck]()
    }
    
    func modifyServingMode(#truckId: String, isInServingMode servingMode: Bool, atLatitude lat: Double, longitude lon: Double) {
        let builder = ServingModeRequest.builder()
        builder.truckId = truckId
        builder.isInServingMode = servingMode
        builder.truckLatitude = lat
        builder.truckLongitude = lon
        apiManager.post(APIRouter.modifyServingMode(builder.build().getNSData()), success: { (response, data) -> () in
            // success
        }) { (response, data, error) -> () in
            // error
        }
    }
}
