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
    var menu: Menu?
    var item1Available = true
    var item2Available = false
    var item3Available = true
    var item4Available = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Menu"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTable")
        
        tblMenu.registerNib(UINib(nibName: "MenuItemTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuItemTableViewCellIdentifier")

        generateTestData()
        
        tblMenu.estimatedRowHeight = 44.0
        tblMenu.rowHeight = UITableViewAutomaticDimension
        tblMenu.reloadData()
    }
    
    func generateTestData() {
        var builder = Menu.builder()
        builder.truckId = "9570d5d3-3caa-46d2-89fd-ae503e032823"
        
        var item1 = MenuItem.builder()
        item1.id = "1"
        item1.isAvailable = item1Available
        item1.name = "Roast Beef"
        item1.notes = "Roast Beef sandwich with Au Jou"
        item1.orderInCategory = 0
        item1.price = 5.75
        item1.tags = ["roast", "beef"]
        
        var item2 = MenuItem.builder()
        item2.id = "2"
        item2.isAvailable = item2Available
        item2.name = "Double Cheese Burger"
        item2.notes = "Pickles, Mayonnaise, Onions, Tomato, Lettuce"
        item2.orderInCategory = 1
        item2.price = 6.75
        item2.tags = ["burger", "cheese"]
        
        var category1 = Category.builder()
        category1.id = "aa65395b-ce29-4524-925b-9ebad1457dbf"
        category1.menuItems = [item1.build(), item2.build()]
        category1.name = "Sandwiches"
        category1.notes = "Free chips and a drink with all sandwiches"
        category1.orderInMenu = 0
        
        var item3 = MenuItem.builder()
        item3.id = "3"
        item3.isAvailable = item3Available
        item3.name = "Coca-Cola"
        item3.orderInCategory = 0
        item3.price = 1.25
        item3.tags = ["roast", "beef"]
        
        var item4 = MenuItem.builder()
        item4.id = "4"
        item4.isAvailable = item4Available
        item4.name = "Water"
        item4.notes = "Aquafina Bottled Water"
        item4.orderInCategory = 1
        item4.price = 1.00
        item4.tags = ["bottled", "water"]
        
        var category2 = Category.builder()
        category2.id = "6e6aaff8-6e8d-49bb-b64b-bb5ba57a08fc"
        category2.menuItems = [item3.build(), item4.build()]
        category2.name = "Drinks"
        category2.orderInMenu = 1
        
        builder.categories = [category1.build(), category2.build()]
        
        menu = builder.build()
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
        for availability in request.diff {
            switch (availability.menuItemId) {
                case "1":
                    item1Available = availability.isAvailable
                case "2":
                    item2Available = availability.isAvailable
                case "3":
                    item3Available = availability.isAvailable
                case "4":
                    item4Available = availability.isAvailable
                default:
                    println("unknown menuItemId \(availability.menuItemId)")
            }
        }
        generateTestData()
    }
    
    func doneEditingTable() {
        let requestBuilder = ModifyMenuItemAvailabilityRequest.builder()
        var diffs = [MenuItemAvailability]()
        for indexPath in selectedCells {
            var currentItem = menu!.categories[indexPath.section].menuItems[indexPath.row]
            
            let diffBuilder = MenuItemAvailability.builder()
            diffBuilder.menuItemId = currentItem.id
            diffBuilder.isAvailable = !currentItem.isAvailable
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
        return menu!.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuItemTableViewCellIdentifier") as MenuItemTableViewCell
        cell.menuItem = menu!.categories[indexPath.section].menuItems[indexPath.row]
        var bgView = UIView()
        bgView.backgroundColor = navigationController?.navigationBar.barTintColor
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu!.categories[section].menuItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menu?.categories[section].name
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
}
