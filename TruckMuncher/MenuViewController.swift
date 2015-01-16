//
//  MenuViewController.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/19/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblMenu: UITableView!
    
    var selectedCells = [NSIndexPath]()
    var menu: RMenu?
    var truckId: String = ""
    
    // TODO: Change this to take in an RTruck, not just the TruckID
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?,truckID truckId: String) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.truckId = truckId
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = UIScreen.mainScreen().bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTable")
        
        tblMenu.registerNib(UINib(nibName: "MenuItemTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuItemTableViewCellIdentifier")
        
        tblMenu.estimatedRowHeight = 44.0
        tblMenu.rowHeight = UITableViewAutomaticDimension
        
        menu = RMenu.objectsWhere("truckId = %@", truckId).firstObject() as? RMenu
        tblMenu.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tblMenu.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendDiffs(request: ModifyMenuItemAvailabilityRequest) {
        /*let data = request.getNSData()
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/x-protobuf", "Accept": "application/x-protobuf", "Authorization": "access_token=CAAJ1PyyMsokBANjy0BYSQqjoWqEFRE8ww7mc2EVZBooOCkHKdR3VnQrINt9EEHORwWRjvFUjFEFqUOaX1gLgsq9c0tzOrAhiZAgoCD0fZA25joKp8zMYaygeKY2ZCDlNZBJg2LDb79AvD20QZAkKfnMgK7nNv75pMTWrDkZBcFeQWz0ZAKuKm2uLn20c9ZBqrcehiH3Tcb9ClHlGZBNCUN3CEvprOgM6Jw0N9ZASkO1pJKaJQZDZD"]
        Alamofire.upload(.POST, "https://api.truckmuncher.com:8443/com.truckmuncher.api.menu.MenuService/modifyMenuItemAvailability", data)
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                println("data \(data)")
                println("error \(error)")
                
                if let nsdata = data as? NSData {
                    var availabilityResponse = ModifyMenuItemAvailabilityResponse.parseFromNSData(nsdata)
                    println("availability response \(availabilityResponse)")
                }
        }*/
        // since protos are immutable and the API route would have to be redesigned for this to work even remotely nice, 
        // this little hack just updates the class level booleans indicating availability and regenerates the entire
        // menu object
//        for availability in request.diff {
//            switch (availability.menuItemId) {
//                case "1":
//                    item1Available = availability.isAvailable
//                case "2":
//                    item2Available = availability.isAvailable
//                case "3":
//                    item3Available = availability.isAvailable
//                case "4":
//                    item4Available = availability.isAvailable
//                default:
//                    println("unknown menuItemId \(availability.menuItemId)")
//            }
//        }
    }
    
    func doneEditingTable() {
        let requestBuilder = ModifyMenuItemAvailabilityRequest.builder()
        var diffs = [MenuItemAvailability]()
        for indexPath in selectedCells {
            var category = menu!.categories.objectAtIndex(UInt(indexPath.section)) as RCategory
            var currentItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as? RMenuItem
            
            let diffBuilder = MenuItemAvailability.builder()
            diffBuilder.menuItemId = currentItem!.id
            diffBuilder.isAvailable = currentItem!.isAvailable
            diffs.append(diffBuilder.build())
        }
        
        requestBuilder.diff = diffs
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.tblMenu.reloadRowsAtIndexPaths(self.selectedCells, withRowAnimation: UITableViewRowAnimation.None)
            self.selectedCells = [NSIndexPath]()
        }
        tblMenu.beginUpdates()
        sendDiffs(requestBuilder.build())
        tblMenu.setEditing(false, animated: true)
        tblMenu.endUpdates()
        
        CATransaction.commit()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTable")
    }
    
    func editTable() {
        tblMenu.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneEditingTable")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu == nil ? 0 : Int(menu!.categories.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuItemTableViewCellIdentifier") as MenuItemTableViewCell
        var category = menu!.categories.objectAtIndex(UInt(indexPath.section)) as RCategory
        cell.menuItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as? RMenuItem
        var bgView = UIView()
        bgView.backgroundColor = navigationController?.navigationBar.barTintColor
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int((menu?.categories.objectAtIndex(UInt(section)) as RCategory).menuItems.count)

    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (menu?.categories.objectAtIndex(UInt(section)) as RCategory).name
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MENU_CATEGORY_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var container = UIView(frame: CGRectMake(0, 0, tblMenu.frame.size.width, 66))
        var label = UILabel(frame: CGRectMake(0, 0, tblMenu.frame.size.width, 66))
        label.textAlignment = .Center
        label.font = UIFont.italicSystemFontOfSize(18.0)
        label.backgroundColor = UIColor.darkGrayColor()
        label.textColor = UIColor.whiteColor()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        container.addSubview(label)
        return container
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !tableView.editing {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            selectedCells.append(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            if let index = find(selectedCells, indexPath) {
                selectedCells.removeAtIndex(index)
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        selectedCells = [indexPath]
        doneEditingTable()
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        var category = menu!.categories.objectAtIndex(UInt(indexPath.section)) as RCategory
        var menuItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as RMenuItem
        return menuItem.isAvailable ? "Out of Stock" : "In Stock"
    }
}
