//
//  TruckCollectionViewCell.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 4/17/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

class TruckCollectionViewCell: UICollectionViewCell {

    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var truckNameField: UILabel!
    @IBOutlet var isServingIndicator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCellWithTruckInfo(truck: RTruck, isServing: Bool){
        layoutIfNeeded()
        getImageForTruck(truck)
        truckNameField.text = truck.name
        isServingIndicator.layer.cornerRadius = isServingIndicator.frame.size.width/2
        isServingIndicator.backgroundColor = isServing == true ? UIColor(rgba: "#0f9d58") : UIColor.lightGrayColor()
    }
    
    func getImageForTruck(truck:RTruck) {
        var imgURL: NSURL? = NSURL(string: truck.imageUrl)
        
        logoImageView.layer.cornerRadius = logoImageView.frame.size.height / 2
        logoImageView.layer.masksToBounds = true
        logoImageView.layer.borderWidth = 0
        
        self.logoImageView.sd_setImageWithURL(imgURL, placeholderImage: UIImage(named: "noImageAvailable"), completed: { (image, error, type, url) -> Void in
            if error == nil {
                self.reloadInputViews()
            }
        })
    }
}
