//
//  VendorMapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/7/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit

class VendorMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    let deltaDegrees = 0.2

    //FUTURE: Usa a xib instead >:(
    var map:MKMapView?
    var locationManager: CLLocationManager!
    
    override init()  {
        super.init(nibName: nil, bundle: nil)
        
        map = MKMapView(frame: UIScreen.mainScreen().bounds)
        map!.delegate = self
        map!.showsUserLocation = true;
        
        view.addSubview(self.map!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        map?.userLocation.addObserver(self, forKeyPath: "location", options: (NSKeyValueObservingOptions.New|NSKeyValueObservingOptions.Old), context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && map!.showsUserLocation){
            var latitude:CLLocationDegrees = map!.userLocation.location.coordinate.latitude
            var longitude:CLLocationDegrees = map!.userLocation.location.coordinate.longitude
            var latDelta:CLLocationDegrees = deltaDegrees
            var longDelta:CLLocationDegrees = deltaDegrees
            
            var aSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
            var Center :CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(Center, aSpan)
            
            map!.setRegion(region, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //FUTURE: Use a neat custom indicator
        return nil
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
}
