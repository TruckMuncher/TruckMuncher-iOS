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
        var dict = [String: AnyObject]()
        dict["latitude"] = lat
        dict["longitude"] = lon
        dict["searchQuery"] = search
        apiManager.post(APIRouter.getActiveTrucks(dict), success: { (response, dict) -> () in
            // success
            var trucks = [RTruck]()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            // TODO this process could use some optimization
            // currently queries one truck, updates properties, writes to DB, repeat
            for truck in dict!["trucks"] as! [[String: AnyObject]] {
                let rresponse = RTruck.objectsWhere("id = %@", truck["id"] as! String)
                var rtruck: RTruck? = nil
                if rresponse.count == 0 {
                    rtruck = RTruck()
                    rtruck!.id = truck["id"] as! String
                } else {
                    rtruck = rresponse[0] as? RTruck
                }
                rtruck!.latitude = truck["latitude"] as! Double
                rtruck!.longitude = truck["longitude"] as! Double
                rtruck!.isInServingMode = true
                realm.addOrUpdateObject(rtruck!)
                trucks.append(rtruck!)
            }
            realm.commitWriteTransaction()
            
            successBlock(response: trucks)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getTrucksForVendor(success successBlock: (response: [RTruck]) -> (), error errorBlock: (error: Error?) -> ()) {
        // TODO if not logged in as vendor, don't even make this request
        apiManager.post(APIRouter.getTrucksForVendor([String: AnyObject]()), success: { (response, dict) -> () in
            // success
            var trucks = [RTruck]()
            
            let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as! String).firstObject() as! RUser
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for truck in dict!["trucks"] as! [[String: AnyObject]] {
                let rresponse = RTruck.objectsWhere("id = %@", truck["id"] as! String)
                var rtruck: RTruck? = nil
                if rresponse.count == 0 {
                    rtruck = RTruck.initFromProto(truck, isNew: false)
                } else {
                    rtruck = rresponse[0] as? RTruck
                    rtruck!.name = truck["name"] as! String
                    rtruck!.imageUrl = truck["imageUrl"] as! String
                    rtruck!.keywords.removeAllObjects()
                    for keyword in truck["keywords"] as! [String] {
                        rtruck!.keywords.addObject(RString.initFromString(keyword))
                    }
                    rtruck!.isNew = false
                    rtruck!.primaryColor = truck["primaryColor"] as! String
                    rtruck!.secondaryColor = truck["secondaryColor"] as! String
                    rtruck!.approved = truck["approved"] as! Bool
                    rtruck!.approvalPending = truck["approvalPending"] as! Bool
                }
                let rstring = RString.initFromString(rtruck!.id)
                if !contains(ruser.truckIds, rstring) {
                    ruser.truckIds.addObject(rstring)
                }
                realm.addOrUpdateObject(rtruck!)
                trucks.append(rtruck!)
            }
            
            realm.addOrUpdateObject(ruser)
            realm.commitWriteTransaction()
            
            successBlock(response: trucks)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getTruckProfiles(atLatitude lat: Double, longitude lon: Double, success successBlock: (response: [RTruck]) -> (), error errorBlock: (error: Error?) -> ()) {
        // TODO returned cached copy instead of network request
        var dict = [String: AnyObject]()
        dict["latitude"] = lat
        dict["longitude"] = lon
        apiManager.post(APIRouter.getTruckProfiles(dict), success: { (response, dict) -> () in
            // success
            var trucks = [RTruck]()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for truck in dict!["trucks"] as! [[String: AnyObject]] {
                let rresponse = RTruck.objectsWhere("id = %@", truck["id"] as! String)
                var rtruck: RTruck? = nil
                if rresponse.count == 0 {
                    rtruck = RTruck.initFromProto(truck, isNew: false)
                } else {
                    rtruck = rresponse[0] as? RTruck
                    rtruck!.name = truck["name"] as! String
                    rtruck!.imageUrl = truck["imageUrl"] as! String
                    rtruck!.keywords.removeAllObjects()
                    for keyword in truck["keywords"] as! [String] {
                        rtruck!.keywords.addObject(RString.initFromString(keyword))
                    }
                    rtruck!.isNew = false
                    rtruck!.primaryColor = truck["primaryColor"] as! String
                    rtruck!.secondaryColor = truck["secondaryColor"] as! String
                    rtruck!.approved = truck["approved"] as! Bool
                    rtruck!.approvalPending = truck["approvalPending"] as! Bool
                }
                realm.addOrUpdateObject(rtruck!)
                trucks.append(rtruck!)
            }
            realm.commitWriteTransaction()
            
            successBlock(response: trucks)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func modifyServingMode(#truckId: String, isInServingMode servingMode: Bool, atLatitude lat: Double, longitude lon: Double, success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["truckId"] = truckId
        dict["isInServingMode"] = servingMode
        dict["truckLatitude"] = lat
        dict["truckLongitude"] = lon
        apiManager.post(APIRouter.modifyServingMode(dict), success: { (response, dict) -> () in
            // success
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            let rtruck = RTruck.objectsWhere("id = %@", truckId)[0] as! RTruck
            rtruck.isInServingMode = servingMode
            rtruck.latitude = lat
            rtruck.longitude = lon
            realm.addOrUpdateObject(rtruck)
            
            realm.commitWriteTransaction()
            
            successBlock()
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
}
