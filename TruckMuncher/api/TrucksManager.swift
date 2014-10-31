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
    
    func getActiveTrucks(atLatitude lat: Double, longitude lon: Double, withSearchQuery search: String, success successBlock: (response: [RTruck]) -> (), error errorBlock: (error: Error?) -> ()) {
        let builder = ActiveTrucksRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        builder.searchQuery = search
        apiManager.post(APIRouter.getActiveTrucks(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            var truckResponse = ActiveTrucksResponse.parseFromNSData(data!)
            var trucks = [RTruck]()
            for truck in truckResponse.trucks {
                trucks.append(RTruck.initFromProto(truck))
            }
            successBlock(response: trucks)
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(nsdata)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getTrucksForVendor(success successBlock: (response: [RTruck]) -> (), error errorBlock: (error: Error?) -> ()) {
        // TODO if not logged in as vendor, don't even make this request
        let builder = TrucksForVendorRequest.builder()
        apiManager.post(APIRouter.getTrucksForVendor(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            var truckResponse = TrucksForVendorResponse.parseFromNSData(data!)
            var trucks = [RTruck]()
            for truck in truckResponse.trucks {
                trucks.append(RTruck.initFromProto(truck, isNew: truckResponse.isNew))
            }
            successBlock(response: trucks)
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(nsdata)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getTruckProfiles(atLatitude lat: Double, longitude lon: Double, success successBlock: (response: [RTruck]) -> (), error errorBlock: (error: Error?) -> ()) {
        // TODO returned cached copy instead of network request
        let builder = TruckProfilesRequest.builder()
        builder.latitude = lat
        builder.longitude = lon
        apiManager.post(APIRouter.getTruckProfiles(builder.build().getNSData()), success: { (response, data) -> () in
            // success
            var truckResponse = TruckProfilesResponse.parseFromNSData(data!)
            var trucks = [RTruck]()
            for truck in truckResponse.trucks {
                trucks.append(RTruck.initFromProto(truck, isNew: false))
            }
            successBlock(response: trucks)
        }) { (response, data, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let nsdata = data {
                errorResponse = Error.parseFromNSData(nsdata)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func modifyServingMode(#truckId: String, isInServingMode servingMode: Bool, atLatitude lat: Double, longitude lon: Double, success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
        let builder = ServingModeRequest.builder()
        builder.truckId = truckId
        builder.isInServingMode = servingMode
        builder.truckLatitude = lat
        builder.truckLongitude = lon
        apiManager.post(APIRouter.modifyServingMode(builder.build().getNSData()), success: { (response, data) -> () in
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
