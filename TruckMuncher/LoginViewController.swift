//
//  LoginViewController.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var fbLoginView: FBLoginView!
    @IBOutlet weak var btnTwitterLogin: UIButton!
    
    var twitterKey: String = ""
    var twitterSecretKey: String = ""
    var twitterName: String = ""
    var twitterCallback: String = ""
    
    let tokenItem = KeychainItemWrapper(identifier: kTwitterOauthToken, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
    let secretItem = KeychainItemWrapper(identifier: kTwitterOauthSecret, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
    var twitterAPI: STTwitterAPI?
    let authManager = AuthManager()
    let truckManager = TrucksManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnTwitterLogin.layer.cornerRadius = 5
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped")
        
        fbLoginView.delegate = self
        fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        twitterAPI = STTwitterAPI(OAuthConsumerName: twitterName, consumerKey: twitterKey, consumerSecret: twitterSecretKey)
        // TODO show some sort of progress dialog signifying a sign in occuring
        if let _ = NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") {
            attemptSessionTokenRefresh({ (error) -> () in
                // we dont have a valid session token from the api
                // let the user decide what they want to do
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        loginToAPI("access_token=\(FBSession.activeSession().accessTokenData.accessToken)")
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
    
    @IBAction func touchDownTwitterButton(sender: AnyObject) {
        btnTwitterLogin.backgroundColor = UIColor(rgba: "#3B89C3")
    }
    
    @IBAction func touchUpTwitterButton(sender: AnyObject) {
        // https://about.twitter.com/press/brand-assets
        btnTwitterLogin.backgroundColor = UIColor(rgba: "#55ACEE")
    }
    
    @IBAction func clickedLoginWithTwitter(sender: AnyObject) {
        touchUpTwitterButton(sender)
        // try to use the saved tokens
        attemptTwitterLogin { () -> Void in
            // if that failed, open up a browser to ask them to login to twitter
            self.twitterAPI?.postTokenRequest({ (url, token) -> Void in
                UIApplication.sharedApplication().openURL(url)
                return
            }, authenticateInsteadOfAuthorize: false, forceLogin: NSNumber(bool: true), screenName: nil, oauthCallback: self.twitterCallback, errorBlock: { (error) -> Void in
                UIAlertView(title: "Login Failed", message: "Could not login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
            })
            return
        }
    }
    
    /**
     * Attempts to reuse tokens stored in the keychain to automatically login to twitter without user interaction.
     */
    func attemptTwitterLogin(errorBlock: () -> Void) {
        let oauthToken = tokenItem.objectForKey(kSecAttrAccount) as! String?
        let oauthSecret = secretItem.objectForKey(kSecValueData) as! String?
        
        if oauthToken != nil && !oauthToken!.isEmpty && oauthSecret != nil && !oauthSecret!.isEmpty {
            twitterAPI = STTwitterAPI(OAuthConsumerName: twitterName, consumerKey: twitterKey, consumerSecret: twitterSecretKey, oauthToken: oauthToken!, oauthTokenSecret: oauthSecret!)
            twitterAPI?.verifyCredentialsWithSuccessBlock({ (username) -> Void in
                self.loginToAPI("oauth_token=\(oauthToken!), oauth_secret=\(oauthSecret!)")
            }, errorBlock: { (error) -> Void in
                // our cached credentials are no longer valid
                self.twitterAPI = STTwitterAPI(OAuthConsumerName: self.twitterName, consumerKey: self.twitterKey, consumerSecret: self.twitterSecretKey)
                errorBlock()
            })
        } else {
            errorBlock()
        }
    }
    
    func verifyTwitterLogin(oauthToken: NSString!, verifier: NSString!) {
        twitterAPI?.postAccessTokenRequestWithPIN(verifier, successBlock: { (token: String!, secret: String!, userId: String!, username: String!) -> Void in
            self.tokenItem.setObject(token, forKey: kSecAttrAccount)
            self.secretItem.setObject(secret, forKey: kSecValueData)
            
            self.loginToAPI("oauth_token=\(token), oauth_secret=\(secret)")
        }, errorBlock: { (error: NSError!) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not verify your login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func successfullyLoggedInAsTruck() {
        navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("loggedInNotification", object: self, userInfo: nil)
        })
    }
    
    func attemptSessionTokenRefresh(error: (Error?) -> ()) {
        truckManager.getTrucksForVendor(success: { (response) -> () in
            self.successfullyLoggedInAsTruck()
        }, error: error)
    }
    
    func loginToAPI(authorizationHeader: String) {
        authManager.signIn(authorization: authorizationHeader, success: { (response) -> () in
            NSUserDefaults.standardUserDefaults().setValue(response.sessionToken, forKey: "sessionToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.attemptSessionTokenRefresh({ (error) -> () in
                println("error \(error)")
                println("error message \(error?.userMessage)")
            })
        }) { (error) -> () in
            println("error \(error)")
            println("error message \(error?.userMessage)")
        }
    }
}
