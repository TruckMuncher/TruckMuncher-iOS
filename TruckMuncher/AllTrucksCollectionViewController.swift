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
    let trucksManager = TrucksManager()
    var menuManager = MenuManager()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, allTrucks: [RTruck]) {
        self.allTrucks = allTrucks
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
        
        self.view.addSubview(collectionView!)
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
        
        cell.updateCellWithTruckInfo(allTrucks[indexPath.row])
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailVC = TruckDetailViewController(nibName: "TruckDetailViewController", bundle: nil, truck: self.allTrucks[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}