//
//  AppDelegate.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var nav: UINavigationController?
    var mapViewController: MapViewController?
    var twitterCallback: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var config: NSDictionary = NSDictionary()
        
        if let path = NSBundle.mainBundle().pathForResource(PROPERTIES_FILE, ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)!
            twitterCallback = config[kTwitterCallback] as? String
        }
        
        application.statusBarStyle = .LightContent
        
        FBSDKLoginButton.self
        
        //wet asphalt background
        UINavigationBar.appearance().barTintColor = pinkColor
        
        UINavigationBar.appearance().translucent = true
        
        //white button text and title
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //white status bar only when using navigation controllers
        UINavigationBar.appearance().barStyle = .Black
        
        let types: UIUserNotificationType = .Badge | .Alert | .Sound
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        mapViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        nav = UINavigationController(rootViewController: mapViewController!)
        self.window!.rootViewController = nav!
        if NSUserDefaults.standardUserDefaults().boolForKey(kFinishedTutorial) {
            let intro = IntroViewController(nibName: "IntroViewController", bundle: nil)
            nav?.pushViewController(intro, animated: false)
        }
        
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
#if RELEASE
        println("release build")
        Twitter.sharedInstance().startWithConsumerKey(config[kTwitterKey] as! String, consumerSecret: config[kTwitterSecretKey] as! String)
        Fabric.with([Crashlytics.startWithAPIKey(config[kCrashlyticsKey] as! String), Twitter.sharedInstance()])
#elseif DEBUG
        println("debug build")
        Twitter.sharedInstance().startWithConsumerKey(config[kTwitterKey] as! String, consumerSecret: config[kTwitterSecretKey] as! String)
        Fabric.with([Twitter.sharedInstance()])
#endif
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
}

