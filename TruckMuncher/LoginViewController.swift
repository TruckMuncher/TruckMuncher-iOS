//
//  LoginViewController.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var fbLoginView: FBLoginView!
    @IBOutlet weak var btnTwitterLogin: UIButton!
    
    let tokenItem = KeychainItemWrapper(identifier: kTwitterOauthToken, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
    let secretItem = KeychainItemWrapper(identifier: kTwitterOauthSecret, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
    var twitterAPI: STTwitterAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginView = FBLoginView()
        
        fbLoginView.delegate = self
        fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        println("twitter oauth token from keychain \(tokenItem.objectForKey(kSecValueData))")
        println("twitter oauth secret from keychain \(secretItem.objectForKey(kSecValueData))")
        
        /*
        TODO Next time just instantiate STTwitter with the class method:
        
        STTwitterAPI(OAuthConsumerName: , consumerKey: , consumerSecret: , oauthToken: , oauthTokenSecret: )
        
        Only do this if the token and secret are populated.
        
        Don't forget to call the twitterAPI?.verifyCredentialsWithSuccessBlock({}, errorBlock:) after that.
        */
        
        twitterAPI = STTwitterAPI(OAuthConsumerName: kTwitterName, consumerKey: kTwitterKey, consumerSecret: kTwitterSecretKey)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        println("This is where you perform a segue.")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println("User Name: \(user.name)")
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    @IBAction func clickedLoginWithTwitter(sender: AnyObject) {
        twitterAPI?.postTokenRequest({ (url: NSURL!, token: String!) -> Void in
            UIApplication.sharedApplication().openURL(url)
            return
        }, authenticateInsteadOfAuthorize: false, forceLogin: NSNumber(bool: true), screenName: nil, oauthCallback: kTwitterCallback, errorBlock: { (error: NSError!) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func verifyTwitterLogin(oauthToken: NSString!, verifier: NSString!) {
        twitterAPI?.postAccessTokenRequestWithPIN(verifier, successBlock: { (token: String!, secret: String!, userId: String!, username: String!) -> Void in
            
            self.tokenItem.setObject(token, forKey: kSecAttrAccount)
            self.secretItem.setObject(secret, forKey: kSecValueData)
            
            // TODO send these tokens off to the API
            
        }) { (error: NSError!) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not verify your login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
}
