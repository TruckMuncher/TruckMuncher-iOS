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
    var locationManager: CLLocationManager!
    var truck: RTruck
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, truck: RTruck) {
        self.truck = truck
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.truck = aDecoder.decodeObjectForKey("vmvcTruck") as RTruck
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(truck, forKey: "vmvcTruck")
    }
    
    @IBAction func onServingModeSwitchTapped(sender: UISwitch) {
        requestServingMode(servingModeSwitch.on)
    }
    
    func openMenu() {
        navigationController?.pushViewController(MenuViewController(nibName: "MenuViewController", bundle: nil, truck: truck), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "openMenu")
        title = truck.name
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        servingModeSwitch.setOn(truck.isInServingMode, animated: false)
        
        changeComponentsColors()
        setMapInteractability()
        setPulse()
    }
    
    func zoomToCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse &&
            locationManager.location != nil{
                
                var latitude = locationManager.location.coordinate.latitude
                var longitude = locationManager.location.coordinate.longitude
                var latDelta = deltaDegrees
                var longDelta = deltaDegrees
                
                var span = MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
                var center = CLLocationCoordinate2DMake(latitude, longitude)
                var region = MKCoordinateRegionMake(center, span)
                
                vendorMapView.setRegion(region, animated: true)
        }
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
        zoomToCurrentLocation()
    }
    
    func changeComponentsColors() {
        servingModeLabel.textColor = truck.isInServingMode ? pinkColor : UIColor.blackColor()
        locationSetterImage.image = truck.isInServingMode ? UIImage(named:"LocationSetterPinPink") : UIImage(named:"LocationSetterPin")
    }
    
    func setMapInteractability () {
        vendorMapView.userInteractionEnabled = !truck.isInServingMode
    }
    
    func setPulse () {
        if truck.isInServingMode {
            pulsingLayer = ServingModePulse()
            pulsingLayer.position = CGPoint(x: locationSetterImage.center.x, y: locationSetterImage.center.y - 10.0)

            view.layer.insertSublayer(pulsingLayer, below: locationSetterImage.layer)
        } else {
            pulsingLayer?.removeFromSuperlayer()
        }
    }
    
    func requestServingMode (isServing: Bool) {
        truckManager.modifyServingMode(truckId: truck.id, isInServingMode: isServing, atLatitude: vendorMapView.centerCoordinate.latitude, longitude: vendorMapView.centerCoordinate.longitude, success: { () -> () in
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
}