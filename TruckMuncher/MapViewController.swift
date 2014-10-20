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
    var loginViewController: LoginViewController?
    @IBAction func loginAction(sender: AnyObject) {
        var config: NSDictionary = NSDictionary()
        
        if let path = NSBundle.mainBundle().pathForResource("Properties", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }
        loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginViewController?.twitterKey = config[kTwitterKey] as String
        loginViewController?.twitterSecretKey = config[kTwitterSecretKey] as String
        loginViewController?.twitterName = config[kTwitterName] as String
        loginViewController?.twitterCallback = config[kTwitterCallback] as String
        navigationController?.pushViewController(loginViewController!, animated: true)
    }
    
    let deltaDegrees = 0.05
    var locationManager: CLLocationManager!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        println("finished locating map")
        view.bringSubviewToFront(loginButton)
    }
    
    func zoomToCurrentLocation() {
        println("zooming to current location")
        if (CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse &&
            locationManager.location != nil){
            println("statement passed")
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
        
        if (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse){
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("location manager did fail with error")
        locationManager.stopUpdatingLocation()
        if (error != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("did change authorization status")
        zoomToCurrentLocation()
    }
}
