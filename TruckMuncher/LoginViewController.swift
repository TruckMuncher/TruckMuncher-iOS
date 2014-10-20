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
        if oauthToken != nil && oauthSecret != nil {
            // TODO show some sort of progress dialog signifying a sign in occuring
            twitterAPI = STTwitterAPI(OAuthConsumerName: twitterName, consumerKey: twitterKey, consumerSecret: twitterSecretKey, oauthToken: oauthToken!, oauthTokenSecret: oauthSecret!)
            twitterAPI?.verifyCredentialsWithSuccessBlock({ (username) -> Void in
                
                self.successfullyLoggedInAsTruck()
            }, errorBlock: { (error) -> Void in
                // our cached credentials are no longer valid, perhaps show a message asking to relogin
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
        successfullyLoggedInAsTruck()
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
        }, authenticateInsteadOfAuthorize: false, forceLogin: NSNumber(bool: true), screenName: nil, oauthCallback: twitterCallback, errorBlock: { (error: NSError!) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        })
    }
    
    func verifyTwitterLogin(oauthToken: NSString!, verifier: NSString!) {
        twitterAPI?.postAccessTokenRequestWithPIN(verifier, successBlock: { (token: String!, secret: String!, userId: String!, username: String!) -> Void in
            
            self.tokenItem.setObject(token, forKey: kSecAttrAccount)
            self.secretItem.setObject(secret, forKey: kSecValueData)
            
            // TODO send these tokens off to the API
            self.successfullyLoggedInAsTruck()
        }) { (error: NSError!) -> Void in
            UIAlertView(title: "Login Failed", message: "Could not verify your login with Twitter, please try again. \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func successfullyLoggedInAsTruck() {
        navigationController?.pushViewController(VendorMapViewController(nibName: "VendorMapViewController", bundle: nil), animated: true)
    }
    
    func loginToAPI(authorizationHeader: String) {
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/json", "Accept": "application/json", "Authorization": authorizationHeader]
        Alamofire.request(.GET, "https://api.truckmuncher.com:8443/auth", parameters: nil, encoding: .JSON)
            .validate(statusCode: [200])
            .responseJSON { (request, response, data, error) -> Void in
                println("JSON response \(data)")
                println("error \(error)")
                println("error message \(error?.localizedDescription)")
        }
    }
}
