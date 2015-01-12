//
//  TruckDetailView.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 1/11/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

class TruckDetailView: UIView {
    
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var truckTagsLabel: UILabel!
    @IBOutlet var truckNameLabel: UILabel!
    @IBOutlet var truckLogoImage: UIImageView!

    func updateViewWithTruck(truck:RTruck!) {
        truckNameLabel.text = truck.id
        truckTagsLabel.text = truck.description
    }
}
