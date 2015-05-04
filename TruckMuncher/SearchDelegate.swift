//
//  SearchDelegate.swift
//  TruckMuncher
//
//  Created by Josh Ault on 1/14/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

protocol SearchCompletionProtocol {
    func searchSuccessful(results: [RTruck])
    func searchCancelled()
}

class SearchDelegate<T: SearchCompletionProtocol where T: UIViewController>: NSObject, UISearchBarDelegate {
    var items = [RLMObject]()
    let searchManager = SearchManager()
    let limit = 20
    var offset = 0
    var previousSearchTerm = ""
    let completionDelegate: T
    let searchBar: UISearchBar
    var titleView: UIView?
    var leftButtons = [AnyObject]()
    var rightButtons = [AnyObject]()
    
    init(completionDelegate: T) {
        self.completionDelegate = completionDelegate
        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "What are you hungry for?"
    }
    
    func showSearchBar() {
        searchBar.becomeFirstResponder()
        titleView = self.completionDelegate.navigationItem.titleView
        leftButtons.extend(self.completionDelegate.navigationItem.leftBarButtonItems!)
        rightButtons.extend(self.completionDelegate.navigationItem.rightBarButtonItems!)
        self.completionDelegate.navigationItem.titleView = searchBar
        self.completionDelegate.navigationItem.leftBarButtonItem = nil
        self.completionDelegate.navigationItem.rightBarButtonItems = nil
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        MBProgressHUD.showHUDAddedTo((completionDelegate as UIViewController).view, animated: true)
        self.searchBar.resignFirstResponder()
        let newTerm = searchBar.text
        if newTerm == "" {
            return
        } else if newTerm != previousSearchTerm {
            previousSearchTerm = newTerm
            offset = 0
        }
        searchManager.simpleSearch(query: newTerm, withLimit: limit, andOffset: offset, success: { (response) -> () in
            self.offset += self.limit
            let results = response as [RSearch]
            let menus = results.map { $0.menu }
            var truckIds = NSMutableSet()
            let trucks = results.map { $0.truck }.filter {
                if truckIds.containsObject($0.id) {
                    return false
                }
                truckIds.addObject($0.id)
                return true
            }
            // we don't get back location info in search, so we have to preserve what we have in our cache
            for truck in trucks {
                if let rtruck = RTruck.objectsWhere("id = %@", truck.id).firstObject() as? RTruck {
                    truck.latitude = rtruck.latitude
                    truck.longitude = rtruck.longitude
                }
            }
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            for menu in menus {
                realm.addOrUpdateObject(menu as RMenu)
            }
            for truck in trucks {
                realm.addOrUpdateObject(truck as RTruck)
            }
            realm.commitWriteTransaction()
            // TODO the blurbs need to be combined and probably used at some point
            MBProgressHUD.hideHUDForView((self.completionDelegate as UIViewController).view, animated: true)
            self.completionDelegate.searchSuccessful(trucks)
        }) { (error) -> () in
            MBProgressHUD.hideHUDForView((self.completionDelegate as UIViewController).view, animated: true)
            println("error performing search \(error)")
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        offset = 0
        previousSearchTerm = ""
        searchBar.text = ""
        searchBar.resignFirstResponder()
        completionDelegate.navigationItem.titleView = titleView
        completionDelegate.navigationItem.leftBarButtonItems = leftButtons
        completionDelegate.navigationItem.rightBarButtonItems = rightButtons
        titleView = nil
        leftButtons = [AnyObject]()
        rightButtons = [AnyObject]()
        completionDelegate.searchCancelled()
    }
}
