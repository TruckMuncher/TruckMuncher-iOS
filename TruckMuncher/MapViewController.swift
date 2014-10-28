//
//  MapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/7/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loginButton: UIButton!
    
    @IBAction func loginAction(sender: AnyObject) { login() }
    
    let deltaDegrees = 0.05
    var locationManager: CLLocationManager!
    var loginViewController: LoginViewController?
    var mapClusterController: CCHMapClusterController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        self.mapView.delegate = self
        
        mapClusterController = CCHMapClusterController(mapView: self.mapView)
        mapClusterController.addAnnotations(getTestData(), withCompletionHandler: nil)
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
            config = NSDictionary(contentsOfFile: path)!
        }
        loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginViewController!.twitterKey = config[kTwitterKey] as String
        loginViewController!.twitterSecretKey = config[kTwitterSecretKey] as String
        loginViewController!.twitterName = config[kTwitterName] as String
        loginViewController!.twitterCallback = config[kTwitterCallback] as String
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushVendorMap", name: "loggedInNotification", object: nil)
        
        loginViewController!.modalPresentationStyle = .OverCurrentContext
        navigationController?.modalTransitionStyle = .CoverVertical
        navigationController?.presentViewController(loginViewController!, animated: true, completion:  nil)
    }
    
    func pushVendorMap() {
        navigationController?.pushViewController(VendorMapViewController(nibName: "VendorMapViewController", bundle: nil), animated: true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getTestData() -> [MKAnnotation] {
        var data: [Double] =
        [43.05265631,-87.90401198,
         43.03576388,-87.91721352,
         43.02638076,-87.90735085,
         43.04600575,-87.90082287,
         43.0476906,-87.90938226,
         43.04207734,-87.9229517,
         43.04833173,-87.89582687,
         43.03738504,-87.89517655,
         43.0290022,-87.91630814,
         43.04188092,-87.91600996,
         43.04538683,-87.90294789,
         43.04069801,-87.90840926,
         43.03756858,-87.90004066,
         43.02641297,-87.91294862,
         43.03851439,-87.91370365,
         43.03334973,-87.91801331,
         43.05091557,-87.91482627,
         43.05074858,-87.89720238,
         43.02518068,-87.90899585,
         43.04223255,-87.91285668,
         43.04306691,-87.92162701,
         43.04274613,-87.90421682,
         43.04925296,-87.90021438,
         43.04333435,-87.89825707,
         43.04386196,-87.90218619,
         43.02695604,-87.90862889]
        
        var points = [MKPointAnnotation]()

        for var i = 0; i < data.count; i+=2 {
            var a = MKPointAnnotation()
            var location = CLLocationCoordinate2D(latitude: data[i], longitude: data[i+1])
            a.setCoordinate(location)
            points.append(a)
        }
        
        return points
    }
}