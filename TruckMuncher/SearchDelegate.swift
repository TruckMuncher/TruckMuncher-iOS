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
    var leftButton: UIBarButtonItem?
    var rightButton: UIBarButtonItem?
    
    init(completionDelegate: T) {
        self.completionDelegate = completionDelegate
        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "What are you hungry for?"
    }
    
    func showSearchBar() {
        searchBar.becomeFirstResponder()
        titleView = self.completionDelegate.navigationItem.titleView
        leftButton = self.completionDelegate.navigationItem.leftBarButtonItem
        rightButton = self.completionDelegate.navigationItem.rightBarButtonItem
        self.completionDelegate.navigationItem.titleView = searchBar
        self.completionDelegate.navigationItem.leftBarButtonItem = nil
        self.completionDelegate.navigationItem.rightBarButtonItem = nil
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("search btn clicked")
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
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            for menu in menus {
                RMenu.createOrUpdateInRealm(realm, withObject: menu as RMenu)
            }
            for truck in trucks {
                RTruck.createOrUpdateInRealm(realm, withObject: truck as RTruck)
            }
            realm.commitWriteTransaction()
            // TODO the blurbs need to be combined and probably used at some point
            self.completionDelegate.searchSuccessful(trucks)
        }) { (error) -> () in
            println("error performing search \(error)")
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        offset = 0
        previousSearchTerm = ""
        searchBar.text = ""
        searchBar.resignFirstResponder()
        completionDelegate.navigationItem.titleView = titleView
        completionDelegate.navigationItem.leftBarButtonItem = leftButton
        completionDelegate.navigationItem.rightBarButtonItem = rightButton
        titleView = nil
        leftButton = nil
        rightButton = nil
        completionDelegate.searchCancelled()
    }
}
