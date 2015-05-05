//
//  MapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/7/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit
import Realm
import TwitterKit

class MapViewController: UIViewController,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    CCHMapClusterControllerDelegate,
    iCarouselDataSource,
    iCarouselDelegate,
    SearchCompletionProtocol,
    UISearchBarDelegate,
    IntroDelegate,
    ShareDialogDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var topMapConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnLinkFb: UIButton!
    @IBOutlet weak var btnLinkTw: UIButton!
    
    var ruser: RUser?
    
    var searchDelegate: SearchDelegate<MapViewController>?
    
    let deltaDegrees = 0.02
    var locationManager: CLLocationManager!
    var loginViewController: LoginViewController?
    var mapClusterController: CCHMapClusterController!
    var truckCarousel: iCarousel!
    var count: Int = 0
    var showingMenu = false
    var originalTrucks = [RTruck]()
    var activeTrucks: [RTruck] = [RTruck]() {
        didSet {
            self.truckCarousel.layer.shadowOpacity = self.activeTrucks.count > 0 ? 0.2 : 0.0
        }
    }
    var allTrucksRegardlessOfServingMode = [RTruck]()
    lazy var btnAllTrucks = UIBarButtonItem()
    var carouselPanGestureRecognizer: UIPanGestureRecognizer?
    lazy var muncherImageView = UIImageView()
    
    let trucksManager = TrucksManager()
    let menuManager = MenuManager()
    let userManager = UserManager()
    let authManager = AuthManager()
    
    var initialTouchY: CGFloat = 0
    var showingIntro = false
    
    var mapMask: CALayer?
    var carouselMask: CALayer?
    
    var popViewControllerFacebook: PopUpViewControllerFacebook?
    var popViewControllerTwitter: PopUpViewControllerTwitter?
    
    func viewAllTrucks() {
        if (allTrucksRegardlessOfServingMode.count > 0){
            let allTrucksVC = AllTrucksCollectionViewController(nibName: "AllTrucksCollectionViewController", bundle: nil, allTrucks: allTrucksRegardlessOfServingMode, activeTrucks: activeTrucks, ruser: ruser)
            navigationController?.pushViewController(allTrucksVC, animated: true)
        } else {
            var alert = UIAlertController(title: "Oops!", message: "No Trucks Loaded", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        
        setupProfile()
        
        carouselPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        carouselPanGestureRecognizer?.enabled = false
        
        var muncherImage = UIImage(named: "transparentTM")
        muncherImageView = UIImageView(image: muncherImage)
        muncherImageView.userInteractionEnabled = true
        muncherImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showProfile"))
        muncherImageView.frame = CGRectMake(0, 0, 40, 40)
        muncherImageView.contentMode = UIViewContentMode.ScaleAspectFit
        navigationItem.titleView = muncherImageView
        
        let btnLogin = UIBarButtonItem(title: "\u{f090}", style: .Plain, target: self, action: "login")
        btnLogin.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 23.0)!], forState: .Normal)
        let invisible = UIBarButtonItem(barButtonSystemItem: .Search, target: nil, action: nil)
        invisible.enabled = false
        invisible.tintColor = UIColor.clearColor()
        
        navigationItem.leftBarButtonItems = [btnLogin, invisible]
        
        searchDelegate = SearchDelegate(completionDelegate: self)
        searchDelegate?.searchBar.delegate = self
        
        btnAllTrucks = UIBarButtonItem(title: "\u{f0c0}", style: .Plain, target: self, action: "viewAllTrucks")
        btnAllTrucks.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 23.0)!], forState: .Normal)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "showSearchBar"), btnAllTrucks]
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !showingIntro {
            updateCarouselWithTruckMenus()
            
            initLocationManager()
            if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
                locationManager.startUpdatingLocation()
                mapClusterControllerSetup()
                truckCarouselSetup()
            }
            setupProfile()
        } else {
            showingIntro = false
        }
    }
    
    func setupProfile() {
        MBProgressHUD.hideHUDForView(view, animated: true)
        ruser = RUser.objectsWhere("sessionToken = %@", (NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as? String) ?? "").firstObject() as? RUser ?? nil
        if truckCarousel != nil {
            truckCarousel.reloadData()
        }
        if let user = ruser {
            muncherImageView.image = UIImage(named: "transparentTMOutline")
            if user.hasFb {
                btnLinkFb.setTitle("Unlink Facebook - \(user.fbUsername)", forState: .Normal)
            } else {
                btnLinkFb.setTitle("Link Facebook", forState: .Normal)
            }
            if user.hasTw {
                btnLinkTw.setTitle("Unlink Twitter - @\(user.twUsername)", forState: .Normal)
            } else {
                btnLinkTw.setTitle("Link Twitter", forState: .Normal)
            }
            let hasTrucks = user.truckIds.count > 0
            if hasTrucks {
                navigationItem.leftBarButtonItem?.title = "\u{f0d1}"
            } else {
                navigationItem.leftBarButtonItem?.title = "\u{f08b}"
            }
        } else {
            muncherImageView.image = UIImage(named: "transparentTM")
            if truckCarousel != nil {
                truckCarousel.reloadData()
            }
            
            navigationItem.leftBarButtonItem?.title = "\u{f090}"
        }
    }
    
    func showProfile() {
        if ruser == nil {
            return
        }
        if mapMask == nil {
            let mm = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
            mm.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            mapMask = mm.layer
        }
        if carouselMask == nil {
            let cm = UIView(frame: CGRectMake(0, 0, truckCarousel.frame.size.width, truckCarousel.frame.size.height))
            cm.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            carouselMask = cm.layer
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mapView.layer.addSublayer(self.mapMask!)
            self.truckCarousel.layer.addSublayer(self.carouselMask!)
            self.mapView.userInteractionEnabled = false
            self.truckCarousel.userInteractionEnabled = false
            self.topMapConstraint.constant = 277
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func hideProfile(sender: AnyObject) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mapMask!.removeFromSuperlayer()
            self.carouselMask!.removeFromSuperlayer()
            self.mapView.userInteractionEnabled = true
            self.truckCarousel.userInteractionEnabled = true
            self.topMapConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func showTutorial(sender: AnyObject) {
        showingIntro = true
        let intro = IntroViewController(nibName: "IntroViewController", bundle: nil)
        intro.delegate = self
        navigationController?.pushViewController(intro, animated: true)
    }
    
    func keepNavBarHidden() -> Bool {
        return true
    }
    
    @IBAction func clickedLinkFb(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        if ruser!.hasFb {
            unlinkFacebook()
            return
        }
        let fbManager = FBSDKLoginManager()
        
        fbManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
            if error != nil {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                let alert = UIAlertController(title: "Oops!", message: "We couldn't link your Facebook account at this time, please try again", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else if !result.isCancelled {
                self.linkFacebook(FBSDKAccessToken.currentAccessToken().tokenString, postActivity: false)
            } else {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        })
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
    
    @IBAction func clickedLinkTw(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        if ruser!.hasTw {
            unlinkTwitter()
            return
        }
        Twitter.sharedInstance().logInWithCompletion {
            (session, error) -> Void in
            if (session != nil) {
                self.linkTwitter(session.authToken, secretToken: session.authTokenSecret, postActivity: false)
            } else {
                Twitter.sharedInstance().logOut()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                let alert = UIAlertController(title: "Oops!", message: "We couldn't link your Twitter account at this time, please try again", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func linkFacebook(accessToken: String, postActivity: Bool) {
        userManager.linkFacebookAccount(accessToken, postActivity: postActivity, success: { (response) -> () in
            self.setupProfile()
        }) { (error) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let alert = UIAlertController(title: "Oops!", message: "\(error!.userMessage)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func unlinkFacebook() {
        if !ruser!.hasTw {
            cantUnlinkLast()
            return
        }
        userManager.unlinkAccount(unlinkFacebook: true, unlinkTwitter: nil, success: { (response) -> () in
            self.setupProfile()
        }) { (error) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let alert = UIAlertController(title: "Oops!", message: "\(error!.userMessage)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func linkTwitter(oauthToken: String, secretToken: String, postActivity: Bool) {
        userManager.linkTwitterAccount(oauthToken, secretToken: secretToken, postActivity: postActivity, success: { (response) -> () in
            self.setupProfile()
        }) { (error) -> () in
            Twitter.sharedInstance().logOut()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let alert = UIAlertController(title: "Oops!", message: "\(error!.userMessage)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func unlinkTwitter() {
        if !ruser!.hasFb {
            cantUnlinkLast()
            return
        }
        userManager.unlinkAccount(unlinkFacebook: nil, unlinkTwitter: true, success: { (response) -> () in
            Twitter.sharedInstance().logOut()
            self.setupProfile()
        }) { (error) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let alert = UIAlertController(title: "Oops!", message: "\(error!.userMessage)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func cantUnlinkLast() {
        MBProgressHUD.hideHUDForView(view, animated: true)
        let alert = UIAlertController(title: "Oops!", message: "You can't unlink your last social media account, please link another before unlinking this one", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func didBecomeActive() {
        /* 
         * In order to mitigate an issue where the navigation bar is shown overlapping
         * the menu when the app returns to the foreground after being minimized, animate it
         * back to its proper location
         */
        if showingMenu {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                let top: CGFloat = 20.0
                var navbarFrame = self.navigationController!.navigationBar.frame
                navbarFrame.origin.y = top-navbarFrame.size.height
                self.navigationController?.navigationBar.frame = navbarFrame
                
                self.navigationItem.titleView?.alpha = 0.0
                let color = (UINavigationBar.appearance().titleTextAttributes![NSForegroundColorAttributeName] as! UIColor).colorWithAlphaComponent(0.0)
                self.navigationItem.leftBarButtonItem?.tintColor = color
                self.navigationItem.rightBarButtonItem?.tintColor = color
                self.btnAllTrucks.tintColor = color
            })
        }
    }
    
    func mapClusterControllerSetup() {
        self.mapView.delegate = self
        
        mapClusterController = CCHMapClusterController(mapView: self.mapView)
        mapClusterController.delegate = self
        mapClusterController.cellSize = 60
        mapClusterController.marginFactor = 0.5
        mapClusterController.maxZoomLevelForClustering = 25
        mapClusterController.minUniqueLocationsForClustering = 2
    }
    
    func truckCarouselSetup() {
        if truckCarousel != nil {
            truckCarousel.removeFromSuperview()
            truckCarousel = nil
        }
        truckCarousel = iCarousel(frame: CGRectMake(0.0, mapView.frame.maxY - 100.0, mapView.frame.size.width, mapView.frame.size.height - 20.0))
        truckCarousel.type = .Linear
        truckCarousel.delegate = self
        truckCarousel.dataSource = self
        truckCarousel.pagingEnabled = true
        truckCarousel.currentItemIndex = 0
        truckCarousel.bounces = true
        truckCarousel.layer.masksToBounds = false
        truckCarousel.layer.shadowColor = UIColor.blackColor().CGColor
        truckCarousel.layer.shadowOffset = CGSizeMake(0.0, -3.0)
        truckCarousel.layer.shadowOpacity = 0.0
        truckCarousel.layer.shadowPath = UIBezierPath(rect: truckCarousel.bounds).CGPath
        
        view.addSubview(truckCarousel)
        attachGestureRecognizerToCarousel()
    }
    
    func showSearchBar() {
        originalTrucks = [RTruck](activeTrucks)
        searchDelegate?.showSearchBar()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchDelegate?.searchBarSearchButtonClicked(searchBar)
            return
        })
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchDelegate?.searchBarCancelButtonClicked(searchBar)
            return
        })
    }
    
    func updateCarouselWithTruckMenus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            menuManager.getFullMenus(atLatitude: 0, longitude: 0, includeAvailability: true, success: { (response) -> () in
                self.trucksManager.getTruckProfiles(atLatitude: 0, longitude: 0, success: { (response) -> () in
                    if self.locationManager != nil {
                        self.updateData()
                    }
                }, error: { (error) -> () in
                        println("error fetching truck profiles \(error)")
                })
            }) { (error) -> () in
                    println("error fetching full menus \(error)")
            }
        }
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView: MKAnnotationView!
        if annotation is CCHMapClusterAnnotation{
            let reuseId = "ClusterAnnotation"
            var clusterAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? TruckLocationAnnotationView
            
            if clusterAnnotationView != nil {
                clusterAnnotationView!.annotation = annotation
            } else {
                clusterAnnotationView = TruckLocationAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                clusterAnnotationView!.canShowCallout = false
            }
            var clusterAnnotation = annotation as! CCHMapClusterAnnotation
            clusterAnnotationView!.count = clusterAnnotation.annotations.count
            clusterAnnotationView!.isUniqueLocation = clusterAnnotation.isUniqueLocation()
            annotationView = clusterAnnotationView!
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        var clusterAnnotation = view.annotation as? CCHMapClusterAnnotation
        var truckLocationAnnotation = clusterAnnotation?.annotations.first as? TruckLocationAnnotation
        
        if let tappedTruckIndex = truckLocationAnnotation?.index {
            truckCarousel.currentItemIndex = tappedTruckIndex
            truckCarousel.scrollToItemAtIndex(tappedTruckIndex, animated: true)
            
        }
    }
    
    // MARK: - CCHMapClusterControllerDelegate Methods

    func mapClusterController(mapClusterController: CCHMapClusterController!, willReuseMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) {
        if var clusterAnnotationView = self.mapView.viewForAnnotation(mapClusterAnnotation!) as? TruckLocationAnnotationView {
            clusterAnnotationView.count = mapClusterAnnotation.annotations.count
            clusterAnnotationView.isUniqueLocation = mapClusterAnnotation.isUniqueLocation()
        }
    }
    
    func zoomToCurrentLocation() {
        if  CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways) &&
            locationManager.location != nil {
                
            centerMapOverCoordinate(locationManager.location.coordinate)
        }
    }
    
    func centerMapOverCoordinate(coordinate: CLLocationCoordinate2D) {
        var latitude = coordinate.latitude
        var longitude = coordinate.longitude
        var latDelta = deltaDegrees
        var longDelta = deltaDegrees
        
        var span = MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
        var center = CLLocationCoordinate2DMake(latitude, longitude)
        var region = MKCoordinateRegionMake(center, span)
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
            mapClusterControllerSetup()
            truckCarouselSetup()
            updateCarouselWithTruckMenus()
            zoomToCurrentLocation()
        }
    }
    
    // MARK: - Helper Methods
    
    func login() {
        if let user = ruser {
            // we are logged in, if we have trucks go to the vendor map
            // if we dont have trucks logout
            if user.truckIds.count > 0 {
                // go to vendor map
                handleLogin()
            } else {
                // logout
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                authManager.signOut(success: { () -> () in
                    // clear some tokens, logout of twitter & facebook
                    self.logoutSuccess()
                }) { (error) -> () in
                    // clear some tokens, logout of twitter & facebook, and pretend we logged out
                    let realm = RLMRealm.defaultRealm()
                    realm.beginWriteTransaction()
                    realm.deleteObjects(RUser.allObjectsInRealm(realm))
                    realm.commitWriteTransaction()
                    
                    self.logoutSuccess()
                }
            }
        } else {
            // we are not logged in, do the normal login flow
            var config: NSDictionary = NSDictionary()
            
            if let path = NSBundle.mainBundle().pathForResource(PROPERTIES_FILE, ofType: "plist") {
                config = NSDictionary(contentsOfFile: path)!
            }
            loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
            loginViewController!.twitterKey = config[kTwitterKey] as! String
            loginViewController!.twitterSecretKey = config[kTwitterSecretKey] as! String
            loginViewController!.twitterName = config[kTwitterName] as! String
            loginViewController!.twitterCallback = config[kTwitterCallback] as! String
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLogin", name: "loggedInNotification", object: nil)
            
            loginViewController!.modalPresentationStyle = .OverCurrentContext
            navigationController?.modalTransitionStyle = .CoverVertical
            navigationController?.presentViewController(UINavigationController(rootViewController: loginViewController!), animated: true, completion:  nil)
        }
    }
    
    func logoutSuccess() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("sessionToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let tokenItem = KeychainItemWrapper(identifier: kTwitterOauthToken, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
        let secretItem = KeychainItemWrapper(identifier: kTwitterOauthSecret, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
        tokenItem.resetKeychainItem()
        secretItem.resetKeychainItem()
        
        FBSDKLoginManager().logOut()
        truckCarousel.reloadData()
        ruser = nil
        muncherImageView.image = UIImage(named: "transparentTM")
        navigationItem.leftBarButtonItem?.title = "\u{f090}"
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
    
    func handleLogin() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as! String).firstObject() as! RUser

        if ruser.truckIds.count > 0 {
            var trucks = [RTruck]()
            for i in 0..<ruser.truckIds.count {
                trucks.append(RTruck.objectsWhere("id = %@", (ruser.truckIds.objectAtIndex(i) as! RString).value).firstObject() as! RTruck)
            }
            
            // Show the VendorMap
            let vendorMapVC = VendorMapViewController(nibName: "VendorMapViewController", bundle: nil, trucks: trucks)
            navigationController?.pushViewController(vendorMapVC, animated: true)
        }
    }
    
    func updateData() {
        let location = locationManager.location
        if location != nil {
            let lat =  locationManager.location.coordinate.latitude
            let long = locationManager.location.coordinate.longitude
            trucksManager.getActiveTrucks(atLatitude: lat, longitude: long, withSearchQuery: String(), success: { (response) -> () in
                self.activeTrucks = self.orderTrucksByDistanceFromCurrentLocation(response as [RTruck])
                self.updateMapWithActiveTrucks()
                self.truckCarousel.reloadData()
                
                
                
                }) { (error) -> () in
                    var alert = UIAlertController(title: "Oops!", message: "We weren't able to load truck locations", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            
            trucksManager.getTruckProfiles(atLatitude: lat, longitude: long, success: { (response) -> () in
                self.allTrucksRegardlessOfServingMode = response as [RTruck]
                }, error: { (error) -> () in
                    var alert = UIAlertController(title: "Oops!", message: "We weren't able to load truck information", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
        }
    }
    
    func orderTrucksByDistanceFromCurrentLocation(trucks: [RTruck]) -> [RTruck] {
        for truck in trucks {
            let distance = locationManager.location.distanceFromLocation(CLLocation(latitude: truck.latitude, longitude: truck.longitude))
            //distanceFromLocation() returns the distance in meters so we need to divide by 1609.344 to convert to miles
            truck.distanceFromMe = (Double)(distance/1609.344)
        }
        
        return trucks.sorted({ $0.distanceFromMe < $1.distanceFromMe })
    }
    
    func updateMapWithActiveTrucks() {
        mapView.removeAnnotations(mapView.annotations)

        var annotations = [TruckLocationAnnotation]()
        
        for i in 0..<activeTrucks.count {
            var location = CLLocationCoordinate2D(latitude: activeTrucks[i].latitude, longitude: activeTrucks[i].longitude)
            var a = TruckLocationAnnotation(location: location, index: i, truckId: activeTrucks[i].id)
            annotations.append(a)
        }
        
        truckCarousel.userInteractionEnabled = activeTrucks.count > 0
        carouselPanGestureRecognizer?.enabled = activeTrucks.count > 0
        
        mapClusterControllerSetup()
        mapClusterController.addAnnotations(annotations, withCompletionHandler: nil)
    }
    
    // MARK: - iCarouselDataSource Methods
    
    func attachGestureRecognizerToCarousel() {
        truckCarousel.addGestureRecognizer(carouselPanGestureRecognizer!)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let bottom = mapView.frame.maxY - 100.0
        let top: CGFloat = 20.0
        let touchLocationOnScreen = recognizer.locationInView(view)
        
        if recognizer.state == .Began {
            navigationController?.navigationBar.userInteractionEnabled = false
            initialTouchY = recognizer.locationInView(truckCarousel).y
        }
        
        let y = min(max(touchLocationOnScreen.y - initialTouchY, top), bottom)
        var frame = truckCarousel.frame
        frame.origin.y = y
        truckCarousel.frame = frame
        
        let percentage = (bottom-y)/(bottom-top)
        
        // fade out the nav bar items as we pull up the menu
        navigationItem.titleView?.alpha = 1-percentage
        let color = (UINavigationBar.appearance().titleTextAttributes![NSForegroundColorAttributeName] as! UIColor).colorWithAlphaComponent(1-percentage)
        navigationItem.leftBarButtonItem?.tintColor = color
        navigationItem.rightBarButtonItem?.tintColor = color
        btnAllTrucks.tintColor = color
        
        // proportionally move the navbar out of sight/back down, but keep the status bar
        var navbarFrame = navigationController!.navigationBar.frame
        navbarFrame.origin.y = min(max(top - percentage*navbarFrame.size.height, top - navbarFrame.size.height), top)
        navigationController?.navigationBar.frame = navbarFrame
        
        let primaryColor = UIColor(rgba: activeTrucks[truckCarousel.currentItemIndex].primaryColor)
        let currentView = truckCarousel.itemViewAtIndex(truckCarousel.currentItemIndex) as! TruckDetailView
        currentView.updateViewWithColor(carouselBackground.transformToColor(primaryColor, withPercentage: percentage))
        
        if recognizer.state == .Ended {
            // if we ended the pan, based on the velocity, we need to snap the menu and nav bar to their final positions as well as fading nav bar items
            let velocity = recognizer.velocityInView(view)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                frame.origin.y = velocity.y > 0 ? bottom : top
                self.truckCarousel.frame = frame
                navbarFrame.origin.y = velocity.y > 0 ? top : top-navbarFrame.size.height
                self.navigationController?.navigationBar.frame = navbarFrame
                self.showingMenu = frame.origin.y == top
                
                self.navigationItem.titleView?.alpha = self.showingMenu ? 0.0 : 1.0
                self.navigationItem.leftBarButtonItem?.tintColor = color.colorWithAlphaComponent(self.showingMenu ? 0.0 : 1.0)
                self.navigationItem.rightBarButtonItem?.tintColor = color.colorWithAlphaComponent(self.showingMenu ? 0.0 : 1.0)
                self.btnAllTrucks.tintColor = color.colorWithAlphaComponent(self.showingMenu ? 0.0 : 1.0)
                
                currentView.updateViewWithColor(self.showingMenu ? primaryColor : carouselBackground)

            }, completion: { (completed) -> Void in
                self.navigationController?.navigationBar.userInteractionEnabled = true
                self.truckCarousel.reloadData()
            })
            initialTouchY = 0
        }
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return max(activeTrucks.count, 1)
    }
    
    @objc func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        var detailView = view
        if view == nil {
            var viewArray = NSBundle.mainBundle().loadNibNamed("TruckDetailView", owner: nil, options: nil)
            var newView = viewArray[0] as! TruckDetailView
            newView.frame = CGRectMake(0.0, 0.0, truckCarousel.frame.size.width, truckCarousel.frame.size.height)
            detailView = newView
        }
        if activeTrucks.count > 0 {
            (detailView as! TruckDetailView).updateViewWithTruck(activeTrucks[index], showingMenu: showingMenu)
            if ruser?.hasFb == true && ruser?.hasTw == true {
                (detailView as! TruckDetailView).shareButton.hidden = false
                (detailView as! TruckDetailView).shareButton.addTarget(self, action: "showShareSheet", forControlEvents: UIControlEvents.TouchUpInside)
            } else if ruser?.hasFb == true {
                (detailView as! TruckDetailView).shareButton.hidden = false
                (detailView as! TruckDetailView).shareButton.addTarget(self, action: "showFacebookShareDialogAction", forControlEvents: UIControlEvents.TouchUpInside)
            } else if ruser?.hasTw == true {
                (detailView as! TruckDetailView).shareButton.hidden = false
                (detailView as! TruckDetailView).shareButton.addTarget(self, action: "showTwitterShareDialog", forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else {
            (detailView as! TruckDetailView).updateViewForNoTruck()
        }
        
        return detailView
    }
    
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
        if FBSDKAccessToken.currentAccessToken() == nil {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
            let fbManager = FBSDKLoginManager()
            
            fbManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if error != nil {
                    let alert = UIAlertController(title: "Oops!", message: "Since you logged in with Twitter, we need you to login with Facebook now to share that to your timeline. Please try again", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if !result.isCancelled {
                    self.showFacebookShareDialog()
                }
            })
        } else {
            if FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions") {
                var truck = activeTrucks[truckCarousel.currentItemIndex]
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
    }
    
    func showTwitterShareDialog() {
        var truck = activeTrucks[truckCarousel.currentItemIndex]
        popViewControllerTwitter = PopUpViewControllerTwitter(nibName: "PopUpViewControllerTwitter", bundle: nil)
        popViewControllerTwitter?.delegate = self
        popViewControllerTwitter?.showInView(view, withMessage: "Check out \(truck.name) on TruckMuncher! https://www.truckmuncher.com/#/trucks/\(truck.id)", animated: true)
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
        for i in 0..<activeTrucks.count {
            let currentCarouselTruckId = (activeTrucks[carousel.currentItemIndex] as RTruck).id
            let someTruck = activeTrucks[i] as RTruck
            if someTruck.id == currentCarouselTruckId {
                let coord = CLLocationCoordinate2D(latitude: someTruck.latitude, longitude: someTruck.longitude)
                centerMapOverCoordinate(coord)
            }
        }
    }
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        if !showingMenu {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: { () -> Void in
                self.truckCarousel.frame = CGRectMake(0.0, self.mapView.frame.maxY - 130.0, self.mapView.frame.size.width, self.mapView.frame.size.height - 20.0)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.truckCarousel.frame = CGRectMake(0.0, self.mapView.frame.maxY - 100.0, self.mapView.frame.size.width, self.mapView.frame.size.height - 20.0)
                }, completion: nil)
            })
        }
    }
    
    // MARK: - ShareDialogDelegate
    
    func shareDialogOpened() {
        truckCarousel.userInteractionEnabled = false
        navigationController?.navigationBar.userInteractionEnabled = false
    }
    
    func shareDialogClosed() {
        truckCarousel.userInteractionEnabled = true
        navigationController?.navigationBar.userInteractionEnabled = true
    }
    
    // MARK: - SearchCompletionProtocol
    
    func searchSuccessful(results: [RTruck]) {
        activeTrucks = orderTrucksByDistanceFromCurrentLocation([RTruck](results))
        updateMapWithActiveTrucks()
        truckCarousel.reloadData()
        truckCarousel.scrollToItemAtIndex(0, animated: false)
    }
    
    func searchCancelled() {
        activeTrucks = [RTruck](originalTrucks)
        originalTrucks = [RTruck]()
        updateMapWithActiveTrucks()
        truckCarousel.reloadData()
        truckCarousel.scrollToItemAtIndex(0, animated: false)
    }
    
}
