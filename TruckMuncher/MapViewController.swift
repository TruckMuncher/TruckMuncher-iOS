//
//  MapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/7/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loginButton: UIButton!
    
    @IBAction func loginAction(sender: AnyObject) { login() }
    
    let deltaDegrees = 0.05
    var locationManager: CLLocationManager!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
    }
    
    func zoomToCurrentLocation() {
        if (CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse &&
            locationManager.location != nil){
                
            var latitude = locationManager.location.coordinate.latitude
            var longitude = locationManager.location.coordinate.longitude
            var latDelta = deltaDegrees
            var longDelta = deltaDegrees
            
            var span = MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
            var center = CLLocationCoordinate2DMake(latitude, longitude)
            var region = MKCoordinateRegionMake(center, span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        zoomToCurrentLocation()
    }
    
    func login () {
        var config: NSDictionary = NSDictionary()
        
        if let path = NSBundle.mainBundle().pathForResource("Properties", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }
        var loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginViewController.twitterKey = config[kTwitterKey] as String
        loginViewController.twitterSecretKey = config[kTwitterSecretKey] as String
        loginViewController.twitterName = config[kTwitterName] as String
        loginViewController.twitterCallback = config[kTwitterCallback] as String
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushVendorMap", name: "loggedInNotification", object: nil)
        
        loginViewController.modalPresentationStyle = .OverCurrentContext
        navigationController?.modalTransitionStyle = .CoverVertical
        navigationController?.presentViewController(loginViewController, animated: true, completion:  nil)
    }
    
    func pushVendorMap() {
        //We need to check if the login was successful somehow
        navigationController?.pushViewController(VendorMapViewController(nibName: "VendorMapViewController", bundle: nil), animated: true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}