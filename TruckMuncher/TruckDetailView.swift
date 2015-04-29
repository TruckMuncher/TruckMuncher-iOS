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
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var shareButton: UIButton!
    
    
    let menuManager = MenuManager()
    
    var menu: RMenu?
    var textColor = UIColor.blackColor()
    var truckId: String!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if menuTableView != nil {
            menuTableView.registerNib(UINib(nibName: "MenuItemTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuItemTableViewCellIdentifier")
            menuTableView.estimatedRowHeight = 44.0
            menuTableView.rowHeight = UITableViewAutomaticDimension
            menuTableView.backgroundView = nil
            menuTableView.backgroundColor = UIColor.clearColor()
        }
        shareButton.setTitleColor(distanceLabel.textColor, forState: .Normal)
    }
    
    func updateViewForNoTruck() {
        menu = RMenu()
        truckNameLabel.text = "No Trucks Currently Active"
        truckLogoImage.image = nil
        imageWidthConstraint.constant = 0.01
        
        let primary = carouselBackground
        backgroundColor = primary
        textColor = primary.suggestedTextColor()
        truckNameLabel.textColor = textColor
        truckTagsLabel.textColor = textColor
        
        distanceLabel.textColor = textColor
    }
    
    func updateViewWithTruck(truck:RTruck!, showingMenu: Bool, showDistance: Bool = true) {
        menu = RMenu.objectsWhere("truckId = %@", truck.id).firstObject() as? RMenu
        if menu == nil {
            menuManager.getMenu(truckId: truck.id, success: { (response) -> () in
                self.menu = response as RMenu
                self.menuTableView.reloadData()
                }) { (error) -> () in
                    println("error \(error)")
            }
        } else {
            self.menuTableView.reloadData()
        }
        self.getImageForTruck(truck)
        
        self.truckNameLabel.text = truck.name
        var keywords = [String]()
        for keyword in truck.keywords {
            keywords.append((keyword as! RString).value)
        }
        self.truckTagsLabel.text = join(", ", keywords)
        
        let primary = showingMenu ? UIColor(rgba: truck.primaryColor) : carouselBackground
        self.backgroundColor = primary
        self.textColor = primary.suggestedTextColor()
        self.truckNameLabel.textColor = self.textColor
        self.truckTagsLabel.textColor = self.textColor
        
        self.distanceLabel.text = showDistance ? String(format: "%.02f mi", truck.distanceFromMe) : ""
        self.distanceLabel.textColor = self.textColor
        
        self.truckId = truck.id
        
        shareButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 30)
        shareButton.setTitle("\u{f045}", forState: .Normal)
    }
    
    func updateViewWithColor(color: UIColor) {
        backgroundColor = color
        textColor = color.suggestedTextColor()
        truckNameLabel.textColor = textColor
        truckTagsLabel.textColor = textColor
        distanceLabel.textColor = textColor
        shareButton.setTitleColor(textColor, forState: .Normal)

        menuTableView.reloadData()
    }
    
    func getImageForTruck(truck:RTruck) {
        var imgURL: NSURL? = NSURL(string: truck.imageUrl)
        
        self.truckLogoImage.sd_setImageWithURL(imgURL, placeholderImage: UIImage(named: "noImageAvailable"), completed: { (image, error, type, url) -> Void in
            if error == nil {
                self.truckLogoImage.layer.cornerRadius = self.truckLogoImage.frame.size.height / 2
                self.truckLogoImage.layer.masksToBounds = true
                self.truckLogoImage.layer.borderWidth = 0
                
                self.menuTableView.reloadData()
            } else {
                println("Error: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK - UITableViewDelegate and UITableViewDataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menu != nil ? Int(menu!.categories.count) : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuItemTableViewCellIdentifier") as! MenuItemTableViewCell
        cell.givenTextColor = textColor
        var category = menu!.categories.objectAtIndex(UInt(indexPath.section)) as! RCategory
        cell.menuItem = category.menuItems.objectAtIndex(UInt(indexPath.row)) as? RMenuItem
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int((menu?.categories.objectAtIndex(UInt(section)) as! RCategory).menuItems.count)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (menu?.categories.objectAtIndex(UInt(section)) as! RCategory).name
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MENU_CATEGORY_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var container = UIView(frame: CGRectMake(0, 0, menuTableView.frame.size.width, MENU_CATEGORY_HEIGHT))
        var label = UILabel(frame: CGRectMake(0, 0, menuTableView.frame.size.width, MENU_CATEGORY_HEIGHT))
        label.textAlignment = .Center
        label.font = UIFont.italicSystemFontOfSize(18.0)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = textColor
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        container.addSubview(label)
        return container
    }
}