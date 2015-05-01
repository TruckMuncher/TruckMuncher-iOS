//
//  PopUpViewControllerFacebook.swift
//  TruckMuncher
//
//  Created by Josh Ault on 4/30/15.
//  Copyright (c) 2015 TruckMuncher, LLC. All rights reserved.
//

import UIKit
import QuartzCore

class PopUpViewControllerFacebook : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentAudience: UISegmentedControl!
    
    var delegate: ShareDialogDelegate?
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard:"))
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        popUpView.layer.cornerRadius = 5
        popUpView.layer.shadowOpacity = 0.8
        popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func showInView(aView: UIView, contentUrl: String, animated: Bool) {
        delegate?.shareDialogOpened()
        view.setTranslatesAutoresizingMaskIntoConstraints(true)
        view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        aView.addSubview(view)
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
    
    func getPrivacyString() -> String {
        // https://developers.facebook.com/docs/graph-api/common-scenarios/
        switch segmentAudience.selectedSegmentIndex {
        case 0:
            return "EVERYONE"
        case 1:
            return "ALL_FRIENDS"
        case 2:
            return "SELF"
        default:
            return "EVERYONE"
        }
    }
    
    @IBAction func post(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        FBSDKGraphRequest(graphPath: "me/feed", parameters: ["message": textView.text, "link": url, "privacy": getPrivacyString()], HTTPMethod: "POST").startWithCompletionHandler { (connection, result, error) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            if error == nil {
                self.closePopup("")
            } else {
                self.errorPosting()
            }
        }
    }
    
    func errorPosting() {
        let alert = UIAlertController(title: "Oops!", message: "We weren't able to post to your Facebook right now, please try again soon", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0
        }, completion:{(finished : Bool)  in
            if finished {
                self.view.removeFromSuperview()
                self.delegate?.shareDialogClosed()
            }
        })
    }
}
