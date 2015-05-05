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
    @IBOutlet weak var lblTags: UILabel!
    
    var givenTextColor = UIColor.blackColor()
        
    var menuItem: RMenuItem? {
        didSet {
            reloadFromMenuItem()
        }
    }
    
    func reloadFromMenuItem() {
        if let item = menuItem {
            var attributes = [NSObject: AnyObject]()
            if !item.isAvailable {
                attributes = [
                    NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue),
                    NSStrikethroughColorAttributeName: givenTextColor,
                    NSForegroundColorAttributeName: givenTextColor
                ]
            }
            lblName.attributedText = NSAttributedString(string: item.name, attributes: attributes)
            lblName.textColor = givenTextColor
            lblPrice.attributedText = NSAttributedString(string: String(format: "$%.2f", item.price), attributes: attributes)
            lblPrice.textColor = givenTextColor
            lblDescription.attributedText = NSAttributedString(string: item.notes, attributes: attributes)
            lblDescription.textColor = givenTextColor
            var tagsString = ""
            for tag in item.tags {
                let val = (tag as! RString).value
                tagsString = "\(tagsString) \(Tag.initFromString(val)?.rawValue ?? val)"
            }
            lblTags.attributedText = NSAttributedString(string: tagsString, attributes: attributes)
            lblTags.textColor = givenTextColor
        }
    }
}