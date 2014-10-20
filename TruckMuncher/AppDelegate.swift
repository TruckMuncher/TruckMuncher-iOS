//
//  AppDelegate.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var nav: UINavigationController?
    var loginViewController: LoginViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var config: NSDictionary = NSDictionary()
        
        if let path = NSBundle.mainBundle().pathForResource("Properties", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }
        
        FBLoginView.self
        
        //wet asphalt background
        UINavigationBar.appearance().barTintColor = wetAsphaltColor
        
        //white button text and title
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //white status bar only when using navigation controllers
        UINavigationBar.appearance().barStyle = .Black
        
        let types: UIUserNotificationType = .Badge | .Alert | .Sound
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        nav = UINavigationController(rootViewController: MapViewController(nibName: "MapViewController", bundle: nil))
        self.window!.rootViewController = self.nav!
        
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        Crashlytics.startWithAPIKey(config[kCrashlyticsKey] as String)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString?, annotation: AnyObject) -> Bool {
        if isTwitterCallbackUrl(url) {
            // pull out the oauth token and verifier and give it back to the login VC
            let queryParams = url.query?.queryParams() as [String: String]! //wtf. the method returns [String: String]! yet i still have to cast to as a forced unwrapped optional
            loginViewController?.verifyTwitterLogin(queryParams[kTwitterOauthToken], verifier: queryParams[kTwitterOauthVerifier])
            return true
        } else {
            var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
            return wasHandled
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func isTwitterCallbackUrl(url: NSURL) -> Bool {
        // try and pull out the twitter callback url string, if successful, we are being redirected from twitter
        let urlString = url.absoluteString!
        return urlString.rangeOfString(kTwitterCallback, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
    }
}

