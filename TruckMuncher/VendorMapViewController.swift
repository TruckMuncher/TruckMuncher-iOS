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
    
    @IBAction func onServingModeSwitchTapped(sender: UISwitch) {
        changeComponentsColors()
        setMapInteractability()
        setPulse()
        requestServingMode(servingModeSwitch.on)
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        navigationController?.pushViewController(MenuViewController(nibName: "MenuViewController", bundle: nil), animated: true)
    }
    
    let deltaDegrees = 0.005
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
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
        servingModeLabel.textColor = servingModeSwitch.on ? pinkColor : UIColor.blackColor()
        navigationController?.navigationBar.barTintColor = servingModeSwitch.on ? pinkColor : UIColor.lightGrayColor()
        locationSetterImage.image = servingModeSwitch.on ? UIImage(named:"LocationSetterPinPink") : UIImage(named:"LocationSetterPin")
    }
    
    func setMapInteractability () {
        vendorMapView.userInteractionEnabled = !servingModeSwitch.on
    }
    
    func setPulse () {
        if servingModeSwitch.on {
            pulsingLayer = ServingModePulse()
            pulsingLayer.position = CGPoint(x: locationSetterImage.center.x, y: locationSetterImage.center.y - 10.0)

            view.layer.insertSublayer(pulsingLayer, below: locationSetterImage.layer)
        } else {
            pulsingLayer.removeFromSuperlayer()
        }
    }
    
    func requestServingMode (isServing: Bool) {
        //TODO un-hard-code this value
        truckManager.modifyServingMode(truckId: "2d1dada3-80f1-4c0e-b878-a02626aafea7", isInServingMode: isServing, atLatitude: vendorMapView.centerCoordinate.latitude, longitude: vendorMapView.centerCoordinate.longitude, success: { () -> () in
            println("success setting serving mode!")
        }) { (error) -> () in
            println("error \(error)")
        }
    }
}