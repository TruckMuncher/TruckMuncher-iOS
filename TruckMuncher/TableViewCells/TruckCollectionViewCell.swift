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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCellWithTruckInfo(truck: RTruck){
        getImageForTruck(truck)
        truckNameField.text = truck.name
    }
    
    func getImageForTruck(truck:RTruck) {
        var imgURL: NSURL? = NSURL(string: truck.imageUrl)
        
        self.logoImageView.sd_setImageWithURL(imgURL, placeholderImage: UIImage(named: "noImageAvailable"), completed: { (image, error, type, url) -> Void in
            if error == nil {
                self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.height / 2
                self.logoImageView.layer.masksToBounds = true
                self.logoImageView.layer.borderWidth = 0
                
                self.reloadInputViews()
            } else {
                println("Error: \(error.localizedDescription)")
            }
        })
    }
}
