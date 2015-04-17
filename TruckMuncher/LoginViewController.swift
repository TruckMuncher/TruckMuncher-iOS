//
//  LoginViewController.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire
import TwitterKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var fbLoginView: FBLoginView!
    @IBOutlet weak var btnTwitterLogin: TWTRLogInButton!
    
    var twitterKey: String = ""
    var twitterSecretKey: String = ""
    var twitterName: String = ""
    var twitterCallback: String = ""
    
    let authManager = AuthManager()
    let truckManager = TrucksManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTwitterLogin.logInCompletion = { (session: TWTRSession!, error: NSError!) in
            #if DEBUG
                self.loginToAPI("oauth_token=tw985c9758-e11b-4d02-9b39-98aa8d00d429, oauth_secret=munch")
            #elseif RELEASE
                self.loginToAPI("oauth_token=\(session.authToken), oauth_secret=\(session.authTokenSecret)")
            #endif
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped")
        
        fbLoginView.delegate = self
        fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
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
        #if DEBUG
            loginToAPI("oauth_token=tw985c9758-e11b-4d02-9b39-98aa8d00d429, oauth_secret=munch")
        #elseif RELEASE
            loginToAPI("access_token=\(FBSession.activeSession().accessTokenData.accessToken)")
        #endif
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
