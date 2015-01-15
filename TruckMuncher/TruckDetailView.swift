//
//  TruckDetailView.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 1/11/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit
import Realm
import Alamofire

class TruckDetailView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var truckTagsLabel: UILabel!
    @IBOutlet var truckNameLabel: UILabel!
    @IBOutlet var truckLogoImage: UIImageView!
    
    var colorPicker = LEColorPicker()
    var colorScheme = LEColorScheme()
    
    var menu: RMenu?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        menuTableView.registerNib(UINib(nibName: "MenuItemTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuItemTableViewCellIdentifier")
        menuTableView.estimatedRowHeight = 44.0
        menuTableView.rowHeight = UITableViewAutomaticDimension
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.separatorStyle = .None
    }
    
    func updateViewWithTruck(truck:RTruck!) {
        menu = RMenu.objectsWhere("truckId = %@", truck.id).firstObject() as? RMenu
        menuTableView.reloadData()
        println(menu?.description)
        
        getImageForTruck(truck)
        
        truckNameLabel.text = truck.name
        var keywords = [String]()
        for keyword in truck.keywords {
            let v = (keyword as RString).value
            print("keyword \(keyword) and \(v)")
            keywords.append((keyword as RString).value)
        }
        truckTagsLabel.text = join(", ", keywords)
        updateColorScheme()
    }
    
    func updateColorScheme() {
        colorScheme = colorPicker.colorSchemeFromImage(truckLogoImage.image)
        menuTableView.backgroundColor = colorScheme.backgroundColor
        backgroundColor = colorScheme.backgroundColor
        truckNameLabel.textColor = colorScheme.primaryTextColor
        truckTagsLabel.textColor = colorScheme.secondaryTextColor
    }
    
    func getImageForTruck(truck:RTruck) {
        var imgURL: NSURL? = NSURL(string: truck.imageUrl)
        
        self.truckLogoImage.sd_setImageWithURL(imgURL, placeholderImage: UIImage(named: "noImageAvailable"), completed: { (image, error, type, url) -> Void in
            if error == nil {
                self.updateColorScheme()
                self.menuTableView.reloadData()
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK - UITableViewDelegate and UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(menu!.categories.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuItemTableViewCellIdentifier") as MenuItemTableViewCell
        var category = menu!.categories.objectAtIndex(UInt(indexPath.section)) as RCategory
        cell.menuItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as? RMenuItem
        cell.backgroundColor = colorScheme.backgroundColor
        cell.lblName.textColor = colorScheme.primaryTextColor
        cell.lblPrice.textColor = colorScheme.primaryTextColor
        cell.lblDescription.textColor = colorScheme.secondaryTextColor
        var bgView = UIView()
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
        var container = UIView(frame: CGRectMake(0, 0, menuTableView.frame.size.width, 66))
        var label = UILabel(frame: CGRectMake(0, 0, menuTableView.frame.size.width, 66))
        label.textAlignment = .Center
        label.font = UIFont.italicSystemFontOfSize(18.0)
        label.backgroundColor = colorScheme.backgroundColor
        label.textColor = colorScheme.primaryTextColor
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        container.addSubview(label)
        return container
    }
}