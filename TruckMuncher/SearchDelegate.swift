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

class SearchDelegate: NSObject, UISearchBarDelegate {
    var items = [RLMObject]()
    let searchManager = SearchManager()
    let limit = 20
    var offset = 0
    var previousSearchTerm = ""
    let completionDelegate: SearchCompletionProtocol
    
    init(completionDelegate: SearchCompletionProtocol) {
        self.completionDelegate = completionDelegate
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let newTerm = searchBar.text
        if newTerm != previousSearchTerm {
            previousSearchTerm = newTerm
            offset = 0
        }
        searchManager.simpleSearch(query: newTerm, withLimit: limit, andOffset: offset, success: { (response) -> () in
            self.offset += self.limit
            let results = response as [RSearch]
            println("found results \(results)")
            let menus = results.map { $0.menu }
            let truckIds = results.map { $0.truck.id }
            let trucks = results.map { $0.truck }.filter { find(truckIds, $0.id) == nil }
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            for menu in menus {
                RMenu.createOrUpdateInRealm(realm, withObject: menu as RMenu)
            }
            for truck in trucks {
                println("found truck \(truck.description)")
                RTruck.createOrUpdateInRealm(realm, withObject: truck as RTruck)
            }
            realm.commitWriteTransaction()
            // TODO the trucks need to be reduced and blurbs combined
            trucks
            self.completionDelegate.searchSuccessful(trucks)
        }) { (error) -> () in
            println("error performing search \(error)")
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
    }
}
