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
    @IBAction func cancelTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var twitterKey: String = ""
    var twitterSecretKey: String = ""
    var twitterName: String = ""
    var twitterCallback: String = ""
    
    let tokenItem = KeychainItemWrapper(identifier: kTwitterOauthToken, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
    let secretItem = KeychainItemWrapper(identifier: kTwitterOauthSecret, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
    var twitterAPI: STTwitterAPI?
    let authManager = AuthManager()
    let mgr = MenuManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginView = FBLoginView()
        
        fbLoginView.delegate = self
        fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
        let oauthToken = tokenItem.objectForKey(kSecAttrAccount) as String?
        let oauthSecret = secretItem.objectForKey(kSecValueData) as String?
        println("twitter oauth token from keychain \(oauthToken)")
        println("twitter oauth secret from keychain \(oauthSecret)")
        
        twitterAPI = STTwitterAPI(OAuthConsumerName: twitterName, consumerKey: twitterKey, consumerSecret: twitterSecretKey)
        if oauthToken != nil && !oauthToken!.isEmpty && oauthSecret != nil && !oauthSecret!.isEmpty {
            // TODO show some sort of progress dialog signifying a sign in occuring
            twitterAPI = STTwitterAPI(OAuthConsumerName: twitterName, consumerKey: twitterKey, consumerSecret: twitterSecretKey, oauthToken: oauthToken!, oauthTokenSecret: oauthSecret!)
            twitterAPI?.verifyCredentialsWithSuccessBlock({ (username) -> Void in
                println("send tokens to API")
                self.loginToAPI("oauth_token=\(oauthToken!), oauth_secret=\(oauthSecret!)")
            }, errorBlock: { (error) -> Void in
                // our cached credentials are no longer valid, perhaps show a message asking to relogin
                println("cached credentials invalid.")
                self.twitterAPI = STTwitterAPI(OAuthConsumerName: self.twitterName, consumerKey: self.twitterKey, consumerSecret: self.twitterSecretKey)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
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
    
    @IBAction func clickedLoginWithTwitter(sender: AnyObject) {
        twitterAPI?.postTokenRequest({ (url, token) -> Void in
            UIApplication.sharedApplication().openURL(url)
            return
        }, authenticateInsteadOfAuthorize: false, forceLogin: NSNumber(bool: true), screenName: nil, oauthCallback: twitterCallback, errorBlock: { (error) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func verifyTwitterLogin(oauthToken: NSString!, verifier: NSString!) {
        twitterAPI?.postAccessTokenRequestWithPIN(verifier, successBlock: { (token: String!, secret: String!, userId: String!, username: String!) -> Void in
            
            println("logged in twitter \(token) and \(secret)")
            println("logged in twitter \(self.twitterAPI?.oauthAccessToken) and \(self.twitterAPI?.oauthAccessTokenSecret)")
            
            self.tokenItem.setObject(token, forKey: kSecAttrAccount)
            self.secretItem.setObject(secret, forKey: kSecValueData)

            self.loginToAPI("oauth_token=\(token), oauth_secret=\(secret)")
        }) { (error: NSError!) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not verify your login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func successfullyLoggedInAsTruck() {
        mgr.getFullMenus(atLatitude: 0, longitude: 0, includeAvailability: true, success: { (response) -> () in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("loggedInNotification", object: self, userInfo: nil)
            })
        }) { (error) -> () in
            println("error fetching full menus \(error)")
        }
    }
    
    func loginToAPI(authorizationHeader: String) {
        authManager.signIn(authorization: authorizationHeader, success: { (response) -> () in
            println("id \(response.id)")
            println("username \(response.username)")
            println("sessionToken \(response.sessionToken)")
            NSUserDefaults.standardUserDefaults().setValue(response.sessionToken, forKey: "sessionToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.successfullyLoggedInAsTruck()
        }) { (error) -> () in
            println("error \(error)")
            println("error message \(error?.userMessage)")
        }
    }
}
