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
    
    var twitterAPI: STTwitterAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginView = FBLoginView()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
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
            println("success \(token) url \(url)")
            UIApplication.sharedApplication().openURL(url)
            
        }, authenticateInsteadOfAuthorize: false, forceLogin: NSNumber(bool: true), screenName: nil, oauthCallback: kTwitterCallback, errorBlock: { (error: NSError!) -> Void in
            println("error \(error)")
        })
    }
    
    func verifyTwitterLogin(oauthToken: NSString!, verifier: NSString!) {
        println("beginning verification")
        twitterAPI?.postAccessTokenRequestWithPIN(verifier, successBlock: { (token: String!, secret: String!, userId: String!, username: String!) -> Void in
            println("successfully verified twitter \(token) \(secret) \(username)")
            /*
            At this point the user can use the API and you can read his access tokens with:
            
            twitterAPI?.oauthAccessToken;
            twitterAPI?.oauthAccessTokenSecret;
            
            TODO store these tokens in keychain so that the user doesn't need to authenticate again on next launch.
            
            Next time just instantiate STTwitter with the class method:
            
            STTwitterAPI(OAuthConsumerName: , consumerKey: , consumerSecret: , oauthToken: , oauthTokenSecret: )
            
            Don't forget to call the twitterAPI?.verifyCredentialsWithSuccessBlock({}, errorBlock:) after that.
            */
            
            // TODO send these tokens off to the API
            
        }) { (error: NSError!) -> Void in
            println("error \(error)")
        }
    }
}
