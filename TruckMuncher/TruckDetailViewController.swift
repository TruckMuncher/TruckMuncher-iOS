//
//  TruckDetailViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 4/17/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

class TruckDetailViewController: UIViewController {

    var truck: RTruck
    var detailView: TruckDetailView
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, truck: RTruck) {
        self.truck = truck
        detailView = TruckDetailView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        truck = RTruck()
        detailView = TruckDetailView()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Truck Details"

        var viewArray = NSBundle.mainBundle().loadNibNamed("TruckDetailView", owner: nil, options: nil)
        detailView = viewArray[0] as! TruckDetailView
        detailView.frame = CGRectMake(0, 64, view.frame.size.width, view.frame.size.height - 64)
        detailView.updateViewWithTruck(truck, showingMenu: true, showDistance: false)

        view.addSubview(detailView)
    }
}