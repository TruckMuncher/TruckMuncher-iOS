//
//  MenuItemTableViewCell.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/19/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    private var privateMenuItem: MenuItem?
    
    var menuItem: MenuItem? {
        set {
            privateMenuItem = newValue
            reloadFromMenuItem()
        }
        get {
            return privateMenuItem
        }
    }
    
    func reloadFromMenuItem() {
        if let item = menuItem {
            var attributes = [NSObject: AnyObject]()
            if !item.isAvailable {
                attributes = [
                    NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue),
                    NSStrikethroughColorAttributeName: UIColor.lightGrayColor(),
                    NSForegroundColorAttributeName: UIColor.lightGrayColor()
                ]
            }
            lblName.attributedText = NSAttributedString(string: item.name, attributes: attributes)
            lblPrice.attributedText = NSAttributedString(string: String(format: "$%.2f", item.price), attributes: attributes)
            lblDescription.attributedText = NSAttributedString(string: item.notes, attributes: attributes)
        }
    }
    
}
