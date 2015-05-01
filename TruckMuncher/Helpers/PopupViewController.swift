//
//  PopUpViewControllerSwift.swift
//  NMPopUpView
//
//  Created by Nikos Maounis on 13/9/14.
//  Copyright (c) 2014 Nikos Maounis. All rights reserved.
//

import UIKit
import QuartzCore

class PopUpViewController : UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        popUpView.layer.cornerRadius = 5
        popUpView.layer.shadowOpacity = 0.8
        popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    func showInView(aView: UIView!, withImage image : UIImage!, withMessage message: String!, animated: Bool) {
        view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        aView.addSubview(view)
        imgLogo.image = image
        lblMessage.text = message
        if animated {
            showAnimate()
        }
    }
    
    func showAnimate() {
        view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        view.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        })
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0
        }, completion:{(finished : Bool)  in
            if finished {
                self.view.removeFromSuperview()
            }
        })
    }
}
