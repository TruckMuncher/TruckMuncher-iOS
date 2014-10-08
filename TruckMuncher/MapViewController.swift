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
    @IBAction func loginAction(sender: AnyObject) {
        var config: NSDictionary = NSDictionary()
        
        if let path = NSBundle.mainBundle().pathForResource("Properties", ofType: "plist") {
            config = NSDictionary(contentsOfFile: path)
        }
        var loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginViewController.twitterKey = config[kTwitterKey] as String
        loginViewController.twitterSecretKey = config[kTwitterSecretKey] as String
        loginViewController.twitterName = config[kTwitterName] as String
        loginViewController.twitterCallback = config[kTwitterCallback] as String
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    let deltaDegrees = 0.05
    var locationManager: CLLocationManager!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.addSubview(mapView)
    }
 
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //zoomToCurrentLocation()
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        view.bringSubviewToFront(loginButton)
    }
    
    func zoomToCurrentLocation() {
        if (CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse &&
            locationManager.location != nil &&
            mapView.showsUserLocation){
                
            var latitude:CLLocationDegrees = locationManager.location.coordinate.latitude
            var longitude:CLLocationDegrees = locationManager.location.coordinate.longitude
            var latDelta:CLLocationDegrees = deltaDegrees
            var longDelta:CLLocationDegrees = deltaDegrees
            
            var span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
            var center :CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(center, span)
            
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
}