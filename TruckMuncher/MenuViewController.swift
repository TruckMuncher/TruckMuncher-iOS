//
//  MenuViewController.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/19/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire
import Realm

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblMenu: UITableView!
    @IBOutlet weak var lblNoItems: UILabel!
    
    var selectedCells = [NSIndexPath]()
    var menu: RMenu
    var truck: RTruck
    let menuManager = MenuManager()
    var textColor = UIColor.blackColor()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, truck: RTruck) {
        self.truck = truck
        menu = RMenu.objectsWhere("truckId = %@", truck.id).firstObject() as? RMenu ?? RMenu()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        self.truck = aDecoder.decodeObjectForKey("mvcTruck") as! RTruck
        self.menu = aDecoder.decodeObjectForKey("mvcMenu") as! RMenu
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(truck, forKey: "mvcTruck")
        aCoder.encodeObject(menu, forKey: "mvcMenu")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if menu.categories.count > 0 {
            lblNoItems.removeFromSuperview()
        }
        
        // http://stackoverflow.com/questions/19456288/text-color-based-on-background-image
        let primary = UIColor(rgba: truck.primaryColor)
        textColor = primary.suggestedTextColor()
        view.backgroundColor = primary
        
        lblNoItems.textColor = textColor
        
        view.frame = UIScreen.mainScreen().bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTable")
        
        tblMenu.registerNib(UINib(nibName: "MenuItemTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuItemTableViewCellIdentifier")
        
        tblMenu.estimatedRowHeight = 99.0
        tblMenu.rowHeight = UITableViewAutomaticDimension
        
        tblMenu.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendDiffs(diffs: [String: Bool]) {
        menuManager.modifyMenuItemAvailability(items: diffs, success: { () -> () in
            println("successfully updated diffs")
            self.menu = RMenu.objectsWhere("truckId = %@", self.truck.id).firstObject() as! RMenu
        }) { (error) -> () in
            println("error updating diffs")
        }
    }
    
    func doneEditingTable() {
        var diffs = [String: Bool]()
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        for indexPath in selectedCells {
            var category = menu.categories.objectAtIndex(UInt(indexPath.section)) as! RCategory
            var currentItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as! RMenuItem
            currentItem.isAvailable = !currentItem.isAvailable
            diffs[currentItem.id] = currentItem.isAvailable
        }
        realm.commitWriteTransaction()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.tblMenu.reloadRowsAtIndexPaths(self.selectedCells, withRowAnimation: UITableViewRowAnimation.None)
            self.selectedCells = [NSIndexPath]()
        }
        tblMenu.beginUpdates()
        sendDiffs(diffs)
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
        return Int(menu.categories.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuItemTableViewCellIdentifier") as! MenuItemTableViewCell
        cell.givenTextColor = textColor
        var category = menu.categories.objectAtIndex(UInt(indexPath.section)) as! RCategory
        cell.menuItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as? RMenuItem
        var bgView = UIView()
        bgView.backgroundColor = view.backgroundColor
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int((menu.categories.objectAtIndex(UInt(section)) as! RCategory).menuItems.count)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (menu.categories.objectAtIndex(UInt(section)) as! RCategory).name
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MENU_CATEGORY_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var container = UIView(frame: CGRectMake(0, 0, tblMenu.frame.size.width, MENU_CATEGORY_HEIGHT))
        var label = UILabel(frame: CGRectMake(0, 0, tblMenu.frame.size.width, MENU_CATEGORY_HEIGHT))
        label.textAlignment = .Center
        label.font = UIFont.italicSystemFontOfSize(18.0)
        label.backgroundColor = view.backgroundColor
        label.textColor = textColor
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
        var category = menu.categories.objectAtIndex(UInt(indexPath.section)) as! RCategory
        var menuItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as! RMenuItem
        return menuItem.isAvailable ? "Out of Stock" : "In Stock"
    }
}
