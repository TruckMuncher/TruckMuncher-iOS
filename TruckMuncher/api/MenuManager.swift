//
//  MenuManager.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/27/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

struct MenuManager {
    let apiManager: APIManager

    init() {
        apiManager = APIManager()
    }
    
    func getMenuItemAvailability(atLatitude lat: Double, longitude lon: Double, success successBlock: (response: [RMenuItem]) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["latitude"] = lat
        dict["longitude"] = lon
        apiManager.post(APIRouter.getMenuItemAvailability(dict), retry: false, success: { (response, dict) -> () in
            // success
            var items = [RMenuItem]()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            // TODO this process could use some optimization
            // currently queries one menu item, updates properties, writes to DB, repeat
            for item in dict!["availabilities"] as! [[String: AnyObject]] {
                let id = item["menuItemId"] as! String
                var rmenuItem = RMenuItem.objectsWhere("id = %@", id)[0] as? RMenuItem
                if rmenuItem == nil {
                    rmenuItem = RMenuItem()
                    rmenuItem!.id = id
                }
                rmenuItem!.isAvailable = item["isAvailable"] as? Bool ?? false
                realm.addOrUpdateObject(rmenuItem!)
                items.append(rmenuItem!)
            }
            realm.commitWriteTransaction()
            
            successBlock(response: items)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getFullMenus(atLatitude lat: Double, longitude lon: Double, includeAvailability avail: Bool, success successBlock: (response: [RMenu]) -> (), error errorBlock: (error: Error?) -> ()) {
        // TODO this should only be run once per time period (TBD). this is our update cache route
        var dict = [String: AnyObject]()
        dict["latitude"] = lat
        dict["longitude"] = lon
        dict["includeAvailability"] = avail
        apiManager.post(APIRouter.getFullMenus(dict), retry: false, success: { (response, dict) -> () in
            // success
            var menus = [RMenu]()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for menu in dict!["menus"] as! [[String: AnyObject]] {
                let rmenu = RMenu.initFromProto(menu)
                menus.append(rmenu)
                realm.addOrUpdateObject(rmenu)
            }
            realm.commitWriteTransaction()
            
            successBlock(response: menus)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func getMenu(#truckId: String, success successBlock: (response: RMenu) -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        dict["truckId"] = truckId
        apiManager.post(APIRouter.getMenu(dict), retry: false, success: { (response, dict) -> () in
            // success
            let rmenu = RMenu.initFromProto(dict!["menu"] as! [String: AnyObject])
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            realm.addOrUpdateObject(rmenu)
            realm.commitWriteTransaction()
            
            successBlock(response: rmenu)
        }) { (response, dict, error) -> () in
            // error
            var errorResponse: Error? = nil
            if let json = dict {
                errorResponse = Error.parseFromDict(json)
            }
            errorBlock(error: errorResponse)
        }
    }
    
    func modifyMenuItemAvailability(#items: [String: Bool], success successBlock: () -> (), error errorBlock: (error: Error?) -> ()) {
        var dict = [String: AnyObject]()
        var diffs = [[String: AnyObject]]()
        for (id, avail) in items {
            var item = [String: AnyObject]()
            item["menuItemId"] = id
            item["isAvailable"] = avail
            diffs.append(item)
        }
        dict["diff"] = diffs
        apiManager.post(APIRouter.modifyMenuItemAvailability(dict), success: { (response, dict) -> () in
            // success
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for (id, available) in items {
                let rmenuItem = RMenuItem.objectsWhere("id = %@", id)[0] as! RMenuItem
                rmenuItem.isAvailable = available
                realm.addOrUpdateObject(rmenuItem)
            }
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
