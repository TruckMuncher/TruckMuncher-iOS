//
//  TruckDetailView.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 1/11/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class TruckDetailView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var truckTagsLabel: UILabel!
    @IBOutlet var truckNameLabel: UILabel!
    @IBOutlet var truckLogoImage: UIImageView!
    
    var menu: Menu?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        menuTableView.registerNib(UINib(nibName: "MenuItemTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MenuItemTableViewCellIdentifier")
        menuTableView.estimatedRowHeight = 44.0
        menuTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func updateViewWithTruck(truck:RTruck!) {
        menu = RMenu.objectsWhere("truckId = %@", truck.id).firstObject() as? Menu
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
        var colorPicker = LEColorPicker()
        var colorScheme = colorPicker.colorSchemeFromImage(truckLogoImage.image)
        menuTableView.backgroundColor = colorScheme.backgroundColor
        backgroundColor = colorScheme.backgroundColor
        truckNameLabel.textColor = colorScheme.primaryTextColor
        truckTagsLabel.textColor = colorScheme.secondaryTextColor
    }
    
    func getImageForTruck(truck:RTruck) {
        var imgURL: NSURL? = NSURL(string: truck.imageUrl)
        
        // Download an NSData representation of the image at the URL
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                self.truckLogoImage.image = UIImage(data: data)
                self.updateColorScheme()
                //TODO: Store these images someplace so we don't have to make network calls all the time
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK - UITableViewDelegate and UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuItemTableViewCellIdentifier") as MenuItemTableViewCell
        cell.menuItem = menu!.categories[indexPath.section].menuItems[indexPath.row]
        var bgView = UIView()
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
        var container = UIView(frame: CGRectMake(0, 0, menuTableView.frame.size.width, 66))
        var label = UILabel(frame: CGRectMake(0, 0, menuTableView.frame.size.width, 66))
        label.textAlignment = .Center
        label.font = UIFont.italicSystemFontOfSize(18.0)
        label.backgroundColor = UIColor.darkGrayColor()
        label.textColor = UIColor.whiteColor()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        container.addSubview(label)
        return container
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}