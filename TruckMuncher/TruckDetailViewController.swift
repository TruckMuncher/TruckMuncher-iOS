//
//  TruckDetailViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 4/17/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

class TruckDetailViewController: UIViewController, ShareDialogDelegate {

    var truck: RTruck
    var ruser: RUser?
    var detailView: TruckDetailView
    
    var popViewControllerFacebook: PopUpViewControllerFacebook?
    var popViewControllerTwitter: PopUpViewControllerTwitter?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, truck: RTruck, user: RUser?) {
        self.truck = truck
        self.ruser = user
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
        
        if ruser?.hasFb == true && ruser?.hasTw == true {
            (detailView as TruckDetailView).shareButton.hidden = false
            (detailView as TruckDetailView).shareButton.addTarget(self, action: "showShareSheet", forControlEvents: UIControlEvents.TouchUpInside)
        } else if ruser?.hasFb == true {
            (detailView as TruckDetailView).shareButton.hidden = false
            (detailView as TruckDetailView).shareButton.addTarget(self, action: "showFacebookShareDialogAction", forControlEvents: UIControlEvents.TouchUpInside)
        } else if ruser?.hasTw == true {
            (detailView as TruckDetailView).shareButton.hidden = false
            (detailView as TruckDetailView).shareButton.addTarget(self, action: "showTwitterShareDialog", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        view.addSubview(detailView)
    }
    
    // MARK: - **FUTURE** EVERYTHING BELOW THIS LINES NEEDS TO BE EXTRACTED INTO A SHARED COMPONENT

    func showShareSheet() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(UIAlertAction(title: "Facebook", style: .Default, handler: { (action) -> Void in
            self.showFacebookShareDialog()
        }))
        sheet.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: { (action) -> Void in
            self.showTwitterShareDialog()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(sheet, animated: true, completion: nil)
    }
    
    func showFacebookShareDialogAction() {
        // yes, this is required, the selector "showFacebookShareDialog:" wont work so we need this
        showFacebookShareDialog()
    }
    
    func showFacebookShareDialog(askPermission: Bool = true) {
        if FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions") {
            popViewControllerFacebook = PopUpViewControllerFacebook(nibName: "PopUpViewControllerFacebook", bundle: nil)
            popViewControllerFacebook?.delegate = self
            popViewControllerFacebook?.showInView(view, contentUrl: "https://www.truckmuncher.com/#/trucks/\(truck.id)", animated: true)
        } else if askPermission {
            // we dont have publishing permissions, ask for them again
            let fbManager = FBSDKLoginManager()
            
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            
            askForPublishingPermissions(fbManager, success: { () -> () in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.showFacebookShareDialog(askPermission: false)
                }, failure: { () -> () in
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    let alert = UIAlertController(title: "Oops!", message: "You'll need to allow TruckMuncher to post to your Facebook in order to use the sharing feature", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func showTwitterShareDialog() {
        popViewControllerTwitter = PopUpViewControllerTwitter(nibName: "PopUpViewControllerTwitter", bundle: nil)
        popViewControllerTwitter?.delegate = self
        popViewControllerTwitter?.showInView(view, withMessage: "Check out \(truck.name) on TruckMuncher! https://www.truckmuncher.com/#/trucks/\(truck.id)", animated: true)
    }
    
    func askForPublishingPermissions(fbManager: FBSDKLoginManager, success: () -> (), failure: () -> ()) {
        fbManager.logInWithPublishPermissions(["publish_actions"], handler: { (result, error) -> Void in
            if error == nil && !result.isCancelled && contains(result.grantedPermissions, "publish_actions") {
                success()
            } else {
                failure()
            }
        })
    }
    
    func shareDialogOpened() {
        navigationController?.navigationBar.userInteractionEnabled = false
    }
    
    func shareDialogClosed() {
        navigationController?.navigationBar.userInteractionEnabled = true
    }
}