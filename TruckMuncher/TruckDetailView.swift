//
//  TruckDetailView.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 1/11/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit
import Realm

class TruckDetailView: UIView {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var truckTagsLabel: UILabel!
    @IBOutlet var truckNameLabel: UILabel!
    @IBOutlet var truckLogoImage: UIImageView!

    func updateViewWithTruck(truck:RTruck!) {
        truckNameLabel.text = truck.name
        var keywords = [String]()
        for keyword in truck.keywords {
            let v = (keyword as RString).value
            print("keyword \(keyword) and \(v)")
            keywords.append((keyword as RString).value)
        }
        truckTagsLabel.text = join(", ", keywords)
        
        var colorPicker = LEColorPicker()
        var colorScheme = colorPicker.colorSchemeFromImage(truckLogoImage.image)
        menuTableView.backgroundColor = colorScheme.backgroundColor
        backgroundColor = colorScheme.backgroundColor
        truckNameLabel.textColor = colorScheme.primaryTextColor
        truckTagsLabel.textColor = colorScheme.secondaryTextColor
    }
    
    func tempTestUpdateWithDifferentImage(truck:RTruck!) {
        truckLogoImage.image = UIImage(named:"MuncherLogo")
        updateViewWithTruck(truck)
    }
}
