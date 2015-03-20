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
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, trucks: [RTruck]) {
        self.trucks = trucks
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.trucks = aDecoder.decodeObjectForKey("vmvcTrucks") as [RTruck]
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
        initLocationManager()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "openMenu")
        initializeTruckTitleLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        servingModeSwitch.setOn(trucks[selectedTruckIndex].isInServingMode, animated: false)
        
        changeComponentsColors()
        setMapInteractability()
        setPulse()
        
        if trucks[selectedTruckIndex].isInServingMode {
            centerMapOverCoordinate(CLLocationCoordinate2D(latitude: trucks[selectedTruckIndex].latitude, longitude: trucks[selectedTruckIndex].longitude))
        }
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
            var pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
            navLabel.addGestureRecognizer(pan)
            createTruckSelectionView()
        }
        
        self.navigationItem.titleView = navLabel
    }
    
    func createTruckSelectionView() {
        
        let count = CGFloat(trucks.count)
        let totalViewHeight = count * selectionViewHeight
        
        truckSelectionView = UIView(frame: CGRectMake(0.0, CGRectGetMaxY(self.navigationController!.navigationBar.frame)-totalViewHeight, UIScreen.mainScreen().bounds.width, totalViewHeight))
        truckSelectionView.backgroundColor = pinkColor.colorWithAlphaComponent(0.75)
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
        truckManager.modifyServingMode(truckId: trucks[selectedTruckIndex].id, isInServingMode: isServing, atLatitude: vendorMapView.centerCoordinate.latitude, longitude: vendorMapView.centerCoordinate.longitude, success: { () -> () in
            println("success setting serving mode!")
            self.changeComponentsColors()
            self.setMapInteractability()
            self.setPulse()
        }) { (error) -> () in
            var alert = UIAlertController(title: "Oops!", message: "We weren't able to update serving mode, please try again", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        var truckSelected = highestTruckIndex - min(Int(point.y-bottomOfNav)/Int(selectionViewHeight), trucks.count-1)
        println(String(format: "%d", truckSelected))
        
//        var i = 0
//        for option in truckSelectionView.subviews as [UIView] {
//            if i == truckSelected {
//                option.backgroundColor = UIColor.lightGrayColor()
//            } else {
//                option.backgroundColor = pinkColor
//            }
//            i += 1
//        }
//
//        if (frame.origin.y > -30) {
//            //highlight logout
//            _lblMenuOptionProfile.layer.shadowOpacity = 0.0;
//            _lblMenuOptionLogout.layer.shadowOpacity = 1.0;
//            _lblMenuOptionSearch.layer.shadowOpacity = 0.0;
//            for (UIView *v in _logoutIndicators) [v setHidden:NO];
//            for (UIView *v in _profileIndicators) [v setHidden:YES];
//            for (UIView *v in _searchIndicators) [v setHidden:YES];
//        } else if (frame.origin.y > -80) {
//            //highlight profile
//            _lblMenuOptionProfile.layer.shadowOpacity = 1.0;
//            _lblMenuOptionLogout.layer.shadowOpacity = 0.0;
//            _lblMenuOptionSearch.layer.shadowOpacity = 0.0;
//            for (UIView *v in _logoutIndicators) [v setHidden:YES];
//            for (UIView *v in _profileIndicators) [v setHidden:NO];
//            for (UIView *v in _searchIndicators) [v setHidden:YES];
//        } else if (frame.origin.y > -130) {
//            //highlight search
//            _lblMenuOptionProfile.layer.shadowOpacity = 0.0;
//            _lblMenuOptionLogout.layer.shadowOpacity = 0.0;
//            _lblMenuOptionSearch.layer.shadowOpacity = 1.0;
//            for (UIView *v in _logoutIndicators) [v setHidden:YES];
//            for (UIView *v in _profileIndicators) [v setHidden:YES];
//            for (UIView *v in _searchIndicators) [v setHidden:NO];
//        } else {
//            _lblMenuOptionProfile.layer.shadowOpacity = 0.0;
//            _lblMenuOptionLogout.layer.shadowOpacity = 0.0;
//            _lblMenuOptionSearch.layer.shadowOpacity = 0.0;
//            for (UIView *v in _logoutIndicators) [v setHidden:YES];
//            for (UIView *v in _profileIndicators) [v setHidden:YES];
//            for (UIView *v in _searchIndicators) [v setHidden:YES];
//        }
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
                
                if self.trucks[self.selectedTruckIndex].isInServingMode {
                    self.centerMapOverCoordinate(CLLocationCoordinate2D(latitude: self.trucks[self.selectedTruckIndex].latitude, longitude: self.trucks[self.selectedTruckIndex].longitude))
                }
            }, completion: { (Bool) -> Void in
                
            })
//            [UIView animateWithDuration:0.3 animations:^{
//                CGRect frame = _menuView.frame;
//                frame.origin.y = -180;
//                [_menuView setFrame:frame];
//                } completion:^(BOOL finished) {
//                if (_lblMenuOptionLogout.layer.shadowOpacity == 1.0) {
//                [_delegate shouldDismissMedicationsViewController];
//                } else if (_lblMenuOptionProfile.layer.shadowOpacity == 1.0) {
//                [self showProfileViewController];
//                } else if (_lblMenuOptionSearch.layer.shadowOpacity == 1.0) {
//                [self searchMedications:self];
//                }
//                _lblMenuOptionProfile.layer.shadowOpacity = 0.0;
//                _lblMenuOptionLogout.layer.shadowOpacity = 0.0;
//                _lblMenuOptionSearch.layer.shadowOpacity = 0.0;
//                }];
        }
    }
}