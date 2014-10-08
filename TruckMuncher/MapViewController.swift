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
    let deltaDegrees = 0.2
    var locationManager: CLLocationManager!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        super.init(nibName: nil, bundle: nil)
        mapView.delegate = self
        mapView.showsUserLocation = true;
        
        view.addSubview(mapView)
    }
 
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        mapView.userLocation.addObserver(self, forKeyPath: "location", options: (NSKeyValueObservingOptions.New|NSKeyValueObservingOptions.Old), context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse && mapView.showsUserLocation){
            var latitude:CLLocationDegrees = mapView.userLocation.location.coordinate.latitude
            var longitude:CLLocationDegrees = mapView.userLocation.location.coordinate.longitude
            var latDelta:CLLocationDegrees = deltaDegrees
            var longDelta:CLLocationDegrees = deltaDegrees
            
            var aSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta,longitudeDelta: longDelta)
            var Center :CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(Center, aSpan)
            
            mapView.setRegion(region, animated: true)
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
