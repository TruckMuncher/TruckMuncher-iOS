//
//  TrucksManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

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
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            // TODO this process could use some optimization
            // currently queries one truck, updates properties, writes to DB, repeat
            for truck in truckResponse.trucks {
                let activeTrucksResponseTruck = truck as ActiveTrucksResponse.Truck
                let rresponse = RTruck.objectsWhere("id = %@", activeTrucksResponseTruck.id)
                var rtruck: RTruck? = nil
                if rresponse.count == 0 {
                    rtruck = RTruck()
                    rtruck!.id = activeTrucksResponseTruck.id
                } else {
                    rtruck = rresponse[0] as? RTruck
                }
                rtruck!.latitude = activeTrucksResponseTruck.latitude
                rtruck!.longitude = activeTrucksResponseTruck.longitude
                rtruck!.isInServingMode = true
                realm.addOrUpdateObject(rtruck!)
                trucks.append(rtruck!)
            }
            realm.commitWriteTransaction()
            
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
            
            let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as String).firstObject() as RUser
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for truck in truckResponse.trucks {
                let rresponse = RTruck.objectsWhere("id = %@", truck.id)
                var rtruck: RTruck? = nil
                if rresponse.count == 0 {
                    rtruck = RTruck.initFromProto(truck, isNew: truckResponse.isNew)
                } else {
                    rtruck = rresponse[0] as? RTruck
                    rtruck!.name = truck.name
                    rtruck!.imageUrl = truck.imageUrl
                    rtruck!.keywords.removeAllObjects()
                    for keyword in truck.keywords {
                        rtruck!.keywords.addObject(RString.initFromString(keyword))
                    }
                    rtruck!.isNew = false
                    rtruck!.primaryColor = truck.primaryColor
                    rtruck!.secondaryColor = truck.secondaryColor
                }
                let rstring = RString.initFromString(rtruck!.id)
                if !contains(ruser.truckIds, rstring) {
                    println("doesnt contain")
                    ruser.truckIds.addObject(rstring)
                }
                realm.addOrUpdateObject(rtruck!)
                trucks.append(rtruck!)
            }
            
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
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
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for truck in truckResponse.trucks {
                let rresponse = RTruck.objectsWhere("id = %@", truck.id)
                var rtruck: RTruck? = nil
                if rresponse.count == 0 {
                    rtruck = RTruck.initFromProto(truck, isNew: false)
                } else {
                    rtruck = rresponse[0] as? RTruck
                    rtruck!.name = truck.name
                    rtruck!.imageUrl = truck.imageUrl
                    rtruck!.keywords.removeAllObjects()
                    for keyword in truck.keywords {
                        rtruck!.keywords.addObject(RString.initFromString(keyword))
                    }
                    rtruck!.isNew = false
                    rtruck!.primaryColor = truck.primaryColor
                    rtruck!.secondaryColor = truck.secondaryColor
                }
                realm.addOrUpdateObject(rtruck!)
                trucks.append(rtruck!)
            }
            realm.commitWriteTransaction()
            
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
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            let rtruck = RTruck.objectsWhere("id = %@", truckId)[0] as RTruck
            rtruck.isInServingMode = servingMode
            rtruck.latitude = lat
            rtruck.longitude = lon
            realm.addOrUpdateObject(rtruck)
            
            realm.commitWriteTransaction()
            
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
