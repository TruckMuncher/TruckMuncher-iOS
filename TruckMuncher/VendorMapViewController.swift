//
//  VendorMapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import Realm
import TwitterKit

class VendorMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let truckManager = TrucksManager()
    @IBOutlet var locationSetterImage: UIImageView!
    @IBOutlet var servingModeLabel: UILabel!
    @IBOutlet var servingModeView: UIVisualEffectView!
    @IBOutlet var vendorMapView: MKMapView!
    @IBOutlet var servingModeSwitch: UISwitch!
    var pulsingLayer : ServingModePulse!
    let deltaDegrees = 0.005
    let selectionViewHeight = CGFloat(45.0)
    var locationManager: CLLocationManager!
    var trucks = [RTruck]()
    var selectedTruckIndex = 0
    var truckSelectionView = UIView()
    var lines = UIView()
    var menu: RMenu = RMenu()
    var menuManager = MenuManager()
    var authManager = AuthManager()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, trucks: [RTruck]) {
        self.trucks = trucks
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.trucks = aDecoder.decodeObjectForKey("vmvcTrucks") as! [RTruck]
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(trucks, forKey: "vmvcTrucks")
    }
    
    @IBAction func onServingModeSwitchTapped(sender: UISwitch) {
        requestServingMode(servingModeSwitch.on)
    }
    
    func openMenu() {
        navigationController?.pushViewController(MenuViewController(nibName: "MenuViewController", bundle: nil, truck: trucks[selectedTruckIndex]), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnLogout = UIButton(frame: CGRectMake(0, 0, 30, 30))
        btnLogout.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnLogout.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        btnLogout.addTarget(self, action: "logout", forControlEvents: .TouchUpInside)
        btnLogout.setTitle("\u{f08b}", forState: .Normal)
        btnLogout.titleLabel?.font = UIFont(name: "FontAwesome", size: 22.0)
        
        let btnMenu = UIButton(frame: CGRectMake(0, 0, 30, 30))
        btnMenu.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnMenu.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        btnMenu.addTarget(self, action: "openMenu", forControlEvents: .TouchUpInside)
        btnMenu.setTitle("\u{f02d}", forState: .Normal)
        btnMenu.titleLabel?.font = UIFont(name: "FontAwesome", size: 22.0)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: btnLogout), UIBarButtonItem(customView: btnMenu)]
        
        if trucks.count == 0 {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: btnLogout)]
            btnMenu.enabled = false
            servingModeSwitch.enabled = false
            var alert = UIAlertController(title: "Uh-oh", message: "You don't have any trucks! You'll need to visit our website and create one.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Go to truckmuncher.com", style: .Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.truckmuncher.com/#/login")!)
                return
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            initLocationManager()
            initializeTruckTitleLabel()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if trucks.count > 0 {
            servingModeSwitch.setOn(trucks[selectedTruckIndex].isInServingMode, animated: false)
            
            changeComponentsColors()
            setMapInteractability()
            setPulse()
            
            if trucks[selectedTruckIndex].isInServingMode {
                centerMapOverCoordinate(CLLocationCoordinate2D(latitude: trucks[selectedTruckIndex].latitude, longitude: trucks[selectedTruckIndex].longitude))
            }
            menuManager.getMenu(truckId: trucks[selectedTruckIndex].id, success: { (response) -> () in
                self.menu = response as RMenu
            }) { (error) -> () in
                println("error \(error)")
            }
        }
    }
    
    func logout() {
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
    
    func logoutSuccess() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("sessionToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let tokenItem = KeychainItemWrapper(identifier: kTwitterOauthToken, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
        let secretItem = KeychainItemWrapper(identifier: kTwitterOauthSecret, accessGroup: (NSBundle.mainBundle().bundleIdentifier!))
        tokenItem.resetKeychainItem()
        secretItem.resetKeychainItem()
        
        FBSDKLoginManager().logOut()
        Twitter.sharedInstance().logOut()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func initializeTruckTitleLabel() {
        
        var navLabel = UILabel()
        navLabel.backgroundColor = UIColor.clearColor()
        navLabel.textColor = UIColor.whiteColor()
        navLabel.text = trucks[selectedTruckIndex].name
        navLabel.textAlignment = .Center
        navLabel.sizeToFit()
        navLabel.userInteractionEnabled = true
        
        if trucks.count > 1 {
            var lines = UIView(frame: CGRectMake((navLabel.bounds.width/2)-10, 23, 20, 5))
            var line1 = UIView(frame: CGRectMake(0, 0, 20, 1))
            var line2 = UIView(frame: CGRectMake(0, 3, 20, 1))
            line1.backgroundColor = UIColor.whiteColor()
            line2.backgroundColor = UIColor.whiteColor()
            lines.addSubview(line1)
            lines.addSubview(line2)
            navLabel.addSubview(lines)
            
            var pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
            navLabel.addGestureRecognizer(pan)
            createTruckSelectionView()
            
            var tap = UITapGestureRecognizer(target: self, action: "handleTap:")
            navLabel.addGestureRecognizer(tap)
        }
        
        self.navigationItem.titleView = navLabel
    }
    
    func createTruckSelectionView() {
        
        let count = CGFloat(trucks.count)
        let totalViewHeight = count * selectionViewHeight
        
        truckSelectionView = UIView(frame: CGRectMake(0.0, CGRectGetMaxY(self.navigationController!.navigationBar.frame) - totalViewHeight, UIScreen.mainScreen().bounds.width, totalViewHeight))
        truckSelectionView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5)
        
        var previousY = CGFloat(0.0)

        for truck in trucks {
            let frame = CGRectMake(0.0, previousY, UIScreen.mainScreen().bounds.width, selectionViewHeight)
            var thisTrucksView = UIView(frame: frame)
            var truckNameLabel = UILabel(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, selectionViewHeight))
            truckNameLabel.textAlignment = .Center
            truckNameLabel.text = truck.name
            truckNameLabel.textColor = UIColor.whiteColor()
            
            thisTrucksView.addSubview(truckNameLabel)
            
            truckSelectionView.addSubview(thisTrucksView)
            previousY += selectionViewHeight
        }
        
        view.addSubview(truckSelectionView)
    }
    
    func zoomToCurrentLocation() {
        if (CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse &&
            locationManager.location != nil){

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
        
        vendorMapView.setRegion(region, animated: true)
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if error != nil {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && !trucks[selectedTruckIndex].isInServingMode){
            zoomToCurrentLocation()
        }
    }
    
    func changeComponentsColors() {
        let isServing = trucks[selectedTruckIndex].isInServingMode
        servingModeLabel.textColor = isServing ? pinkColor : UIColor.blackColor()
        locationSetterImage.image = isServing ? UIImage(named:"LocationSetterPinPink") : UIImage(named:"LocationSetterPin")
        servingModeSwitch.setOn(isServing, animated: true)
    }
    
    func setMapInteractability () {
        vendorMapView.userInteractionEnabled = !trucks[selectedTruckIndex].isInServingMode
    }
    
    func setPulse () {
        pulsingLayer?.removeFromSuperlayer()

        if trucks[selectedTruckIndex].isInServingMode {
            pulsingLayer = ServingModePulse()
            pulsingLayer.position = CGPoint(x: locationSetterImage.center.x, y: locationSetterImage.center.y - 10.0)

            view.layer.insertSublayer(pulsingLayer, below: locationSetterImage.layer)
        }
    }
    
    func requestServingMode (isServing: Bool) {
        var itemsOutOfStock = getOutOfStockItems()
        if itemsOutOfStock.count > 0 && isServing == true {
            var message = String()
            for item in itemsOutOfStock {
                message += "- " + (item as RMenuItem).name + "\n"
            }
            var alert = UIAlertController(title: "Continue with these items out of stock?", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { (alert: UIAlertAction!) in self.servingModeSwitch.setOn(false, animated: true)}))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in self.setServingMode(isServing) }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            setServingMode(isServing)
        }
    }
    
    func setServingMode (isServing:Bool) {
        if !trucks[selectedTruckIndex].approved {
            let alert = UIAlertController(title: "Unapproved Truck", message: "You need to request that your truck be approved by the TruckMuncher team before you can put it into serving mode. Visit our website to request approval!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Visit our website", style: .Default, handler: { (alert: UIAlertAction!) in
                self.servingModeSwitch.setOn(false, animated: true)
                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.truckmuncher.com/#/login")!)
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            self.servingModeSwitch.on = !isServing
            return
        }
        truckManager.modifyServingMode(truckId: trucks[selectedTruckIndex].id, isInServingMode: isServing, atLatitude: vendorMapView.centerCoordinate.latitude, longitude: vendorMapView.centerCoordinate.longitude, success: { () -> () in
            println("success setting serving mode!")
            self.changeComponentsColors()
            self.setMapInteractability()
            self.setPulse()
            }) { (error) -> () in
                var alert = UIAlertController(title: "Oops!", message: "We weren't able to update serving mode, please try again", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.servingModeSwitch.on = !isServing
        }
    }

    func getOutOfStockItems () -> [RMenuItem] {
        var itemsOutOfStock = [RMenuItem]()
        for category in menu.categories {
            for menuItem in (category as! RCategory).menuItems {
                let item = menuItem as! RMenuItem
                if !item.isAvailable {
                    itemsOutOfStock.append(item)
                }
            }
        }
        return itemsOutOfStock
    }
    
    func handlePan(pan: UIPanGestureRecognizer) {
        let count = CGFloat(trucks.count)
        let totalViewHeight = count * selectionViewHeight
        var point = pan.locationInView(self.view)
        var frame = truckSelectionView.frame
        let bottomOfNav = CGRectGetMaxY(self.navigationController!.navigationBar.frame)
        frame.origin.y = min(point.y-totalViewHeight, bottomOfNav)
        truckSelectionView.frame = frame
        
        let highestTruckIndex = trucks.count-1
        var truckSelected = highestTruckIndex - max(0, min(Int(point.y-bottomOfNav-10)/Int(selectionViewHeight), trucks.count-1))
        
        for (index, view) in enumerate(truckSelectionView.subviews) {
            (view as! UIView).backgroundColor = UIColor.clearColor()
            if index == truckSelected {
                (view as! UIView).backgroundColor = pinkColor.colorWithAlphaComponent(0.75)
            }
        }
        
        if pan.state == .Ended {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                var frame = self.truckSelectionView.frame
                frame.origin.y = -totalViewHeight
                self.truckSelectionView.frame = frame
                self.selectedTruckIndex = truckSelected
                self.initializeTruckTitleLabel()
                self.changeComponentsColors()
                self.setMapInteractability()
                self.setPulse()
                self.menuManager.getMenu(truckId: self.trucks[self.selectedTruckIndex].id, success: { (response) -> () in
                    self.menu = response as RMenu
                }) { (error) -> () in
                    println("error \(error)")
                }
                
                if self.trucks[self.selectedTruckIndex].isInServingMode {
                    self.centerMapOverCoordinate(CLLocationCoordinate2D(latitude: self.trucks[self.selectedTruckIndex].latitude, longitude: self.trucks[self.selectedTruckIndex].longitude))
                }
            }, completion: { (Bool) -> Void in
                
            })
        }
    }
    
    func handleTap(tap: UITapGestureRecognizer) {
        let count = CGFloat(trucks.count)
        let totalViewHeight = count * selectionViewHeight

        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: { () -> Void in
            self.truckSelectionView.frame = CGRectMake(0.0, CGRectGetMaxY(self.navigationController!.navigationBar.frame) - totalViewHeight + 20, UIScreen.mainScreen().bounds.width, totalViewHeight)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.truckSelectionView.frame = CGRectMake(0.0, CGRectGetMaxY(self.navigationController!.navigationBar.frame) - totalViewHeight, UIScreen.mainScreen().bounds.width, totalViewHeight)
                    }, completion: nil)
        })
    }
}