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
    
    let deltaDegrees = 0.005
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
                
                vendorMapView.setRegion(region, animated: true)
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
    
    func changeComponentsColors() {
        servingModeLabel.textColor = servingModeSwitch.on ? Colors().pink : UIColor.blackColor()
        navigationController?.navigationBar.barTintColor = servingModeSwitch.on ? Colors().pink : Colors().wetAsphalt
        locationSetterImage.image = servingModeSwitch.on ? UIImage(named:"LocationSetterPinPink.png") : UIImage(named:"LocationSetterPin.png")
    }
    
    func setMapInteractability () {
        vendorMapView.userInteractionEnabled = !servingModeSwitch.on
    }
    
    func setPulse () {
        if (servingModeSwitch.on) {
            pulsingLayer = ServingModePulse()
            pulsingLayer.position = CGPoint(x: locationSetterImage.center.x, y: locationSetterImage.center.y - 10.0)

            view.layer.insertSublayer(pulsingLayer, below: locationSetterImage.layer)
        } else {
            pulsingLayer.removeFromSuperlayer()
        }
    }
    
    func requestServingMode (isServing: Bool) {
        let requestBuilder = ServingModeRequest.builder()
        requestBuilder.truckId = "9570d5d3-3caa-46d2-89fd-ae503e032823" //TODO un-hard-code this value
        requestBuilder.truckLatitude = vendorMapView.centerCoordinate.latitude
        requestBuilder.truckLongitude = vendorMapView.centerCoordinate.longitude
        requestBuilder.isInServingMode = isServing
        let servingModeRequest = requestBuilder.build()
        let data = servingModeRequest.getNSData()
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/x-protobuf", "Accept": "application/x-protobuf", "Authorization": "access_token=\(FBSession.activeSession().accessTokenData.accessToken)"]
        Alamofire.upload(.POST, "https://api.truckmuncher.com:8443/com.truckmuncher.api.trucks.TruckService/modifyServingMode", data)
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                println("data \(data)")
                println("error \(error)")
                
                if let nsdata = data as? NSData {
                    var truckResponse = ServingModeResponse.parseFromNSData(nsdata)
                    println("serving mode request response \(truckResponse)")
                }
        }
    }
}