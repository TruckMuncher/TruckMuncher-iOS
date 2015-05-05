//
//  AllTrucksCollectionViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 4/17/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class AllTrucksCollectionViewController: UICollectionViewController {
    
    var allTrucks: [RTruck] = [RTruck]()
    var activeTrucks: [RTruck] = [RTruck]()
    let trucksManager = TrucksManager()
    var menuManager = MenuManager()
    var ruser: RUser?
    var lat = 0.0
    var long = 0.0
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, lat: Double, long: Double, activeTrucks: [RTruck], ruser: RUser?) {
        self.lat = lat
        self.long = long
        self.activeTrucks = activeTrucks
        self.ruser = ruser
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "All Trucks"
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        var width = (UIScreen.mainScreen().bounds.width - 30) / 2 // 30 for the left, right, and interitem spacing
        layout.itemSize = CGSize(width: width, height: width)
        
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = UIColor.whiteColor()

        // Register cell classes
        collectionView!.registerNib(UINib(nibName: "TruckCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: reuseIdentifier)
        
        view.addSubview(collectionView!)
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        trucksManager.getTruckProfiles(atLatitude: lat, longitude: long, success: { (response) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.allTrucks = response as [RTruck]
            self.collectionView?.reloadData()
        }, error: { (error) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let alert = UIAlertController(title: "Oops!", message: "We weren't able to load all the truck information, please try again", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTrucks.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TruckCollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        
        let truck = allTrucks[indexPath.row]
        let isActive = contains(activeTrucks, truck)
        cell.updateCellWithTruckInfo(truck, isServing: isActive)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailVC = TruckDetailViewController(nibName: "TruckDetailViewController", bundle: nil, truck: self.allTrucks[indexPath.row], user: ruser)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}