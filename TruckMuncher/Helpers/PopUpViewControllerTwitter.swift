//
//  PopUpViewControllerTwitter.swift
//  TruckMuncher
//
//  Created by Josh Ault on 4/30/15.
//  Copyright (c) 2015 TruckMuncher, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import TwitterKit

class PopUpViewControllerTwitter : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblChars: UILabel!
    @IBOutlet weak var btnPost: UIBarButtonItem!
    
    var delegate: ShareDialogDelegate?
    
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
    
    func showInView(aView: UIView, withMessage message: String, animated: Bool) {
        delegate?.shareDialogOpened()
        view.setTranslatesAutoresizingMaskIntoConstraints(true)
        view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        aView.addSubview(view)
        textView.text = message
        let charCount = 140 - count(message)
        lblChars.text = "\(charCount)"
        btnPost.enabled = charCount >= 0
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
    
    @IBAction func post(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        let statusUpdateEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
        let params = ["status": textView.text]
        var error : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("POST", URL: "https://api.twitter.com/1.1/statuses/update.json", parameters: ["status": textView.text], error: &error)
        
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: { (response, data, connectionError) -> Void in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if (connectionError == nil) {
                    self.closePopup("")
                } else {
                    self.errorPosting()
                }
            })
        } else {
            MBProgressHUD.hideHUDForView(view, animated: true)
            errorPosting()
        }
    }
    
    func errorPosting() {
        let alert = UIAlertController(title: "Oops!", message: "We weren't able to send that tweet right now, please try again soon", preferredStyle: .Alert)
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var currentText: NSString = textView.text
        var updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        let charCount = 140 - count(updatedText)
        lblChars.text = "\(charCount)"
        btnPost.enabled = charCount >= 0
        
        return true
    }
}
