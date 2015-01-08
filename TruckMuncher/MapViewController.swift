//
//  MapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/7/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    CCHMapClusterControllerDelegate,
    iCarouselDataSource,
    iCarouselDelegate,
    UIViewControllerTransitioningDelegate  {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var truckCarousel: iCarousel!
    
    var items: [Int] = []
    
    @IBAction func loginAction(sender: AnyObject) { login() }
    
    let deltaDegrees = 0.05
    var locationManager: CLLocationManager!
    var loginViewController: LoginViewController?
    var mapClusterController: CCHMapClusterController!
    var count: Int = 0
    var activeTrucks = [RTruck]()
    
    let trucksManager = TrucksManager()
    
    var transitionManager = TransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        self.mapView.delegate = self

        mapClusterController = CCHMapClusterController(mapView: self.mapView)
        mapClusterController.delegate = self
        setClusterSettings()
        
        for i in 0...99
        {
            items.append(i)
        }
        
        truckCarousel.type = .Linear
        truckCarousel.delegate = self
        truckCarousel.dataSource = self
        truckCarousel.pagingEnabled = true
        truckCarousel.currentItemIndex = 0
        
//        updateData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateData()
    }
    
    func setClusterSettings() {
        mapClusterController.cellSize = 60
        mapClusterController.marginFactor = 0.5
        mapClusterController.maxZoomLevelForClustering = 25
        mapClusterController.minUniqueLocationsForClustering = 2
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
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var annotationView: MKAnnotationView!
        if annotation is CCHMapClusterAnnotation{
            let reuseId = "ClusterAnnotation"
            var clusterAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? TruckLocationAnnotationView
            
            if clusterAnnotationView != nil {
                clusterAnnotationView!.annotation = annotation
            } else {
                clusterAnnotationView = TruckLocationAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                clusterAnnotationView!.canShowCallout = false
            }
            var clusterAnnotation = annotation as CCHMapClusterAnnotation
            clusterAnnotationView!.setCount(clusterAnnotation.annotations.count)
            clusterAnnotationView!.isUniqueLocation = clusterAnnotation.isUniqueLocation()
            annotationView = clusterAnnotationView!
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        var clusterAnnotation = view.annotation as? CCHMapClusterAnnotation
        var truckLocationAnnotation = clusterAnnotation?.annotations.allObjects[0] as? TruckLocationAnnotation
        
        let tappedTruckIndex = truckLocationAnnotation!.index
        
        truckCarousel.currentItemIndex = tappedTruckIndex
        truckCarousel.scrollToItemAtIndex(tappedTruckIndex, animated: true)
        
        centerMapOverCoordinate(truckLocationAnnotation!.coordinate)
    }
    
    // MARK: - CCHMapClusterControllerDelegate Methods

    func mapClusterController(mapClusterController: CCHMapClusterController!, willReuseMapClusterAnnotation mapClusterAnnotation: CCHMapClusterAnnotation!) {
        if var clusterAnnotationView = self.mapView.viewForAnnotation(mapClusterAnnotation!) as? TruckLocationAnnotationView {
            clusterAnnotationView.setCount(mapClusterAnnotation.annotations.count)
            clusterAnnotationView.isUniqueLocation = mapClusterAnnotation.isUniqueLocation()
        }
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
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        zoomToCurrentLocation()
    }
    
    // MARK: - Helper Methods
    
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
        navigationController?.pushViewController(VendorMapViewController(nibName: "VendorMapViewController", bundle: nil), animated: true)
    }
    
    func updateData() {
        let lat = locationManager.location.coordinate.latitude
        let long = locationManager.location.coordinate.longitude
        trucksManager.getActiveTrucks(atLatitude: lat, longitude: long, withSearchQuery: String(), success: { (response) -> () in
            self.activeTrucks = response as [RTruck]
            self.updateMapWithActiveTrucks()
            self.truckCarousel.reloadData()

        }) { (error) -> () in
            var alert = UIAlertController(title: "Oops!", message: "We weren't able to load truck locations", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func updateMapWithActiveTrucks() {
        var annotations = [TruckLocationAnnotation]()
        
        for var i = 0; i < activeTrucks.count; i++ {
            var location = CLLocationCoordinate2D(latitude: activeTrucks[i].latitude, longitude: activeTrucks[i].longitude)
            var a = TruckLocationAnnotation(location: location, index: i)
            annotations.append(a)
        }
        
        mapClusterController = CCHMapClusterController(mapView: self.mapView)
        mapClusterController.addAnnotations(annotations, withCompletionHandler: nil)
    }
    
    func presentMenu() {
        var menu = UIViewController()
        menu.transitioningDelegate = self
        menu.modalPresentationStyle = .Custom
        self.presentViewController(menu, animated: true) { () -> Void in
            
        }
    }
    
    // MARK: - iCarouselDataSource Methods
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return activeTrucks.count
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
    {
        var truckNameLabel: UILabel! = nil
        var truckDetailsLabel: UILabel! = nil
        var truckLogo: UIImageView! = nil
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            // TODO construct all of this from a .xib and save yourself ~30-40 lines of code
            
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            let padding:CGFloat = 5.0
            view = UIView(frame:CGRectMake(0, 0, self.view.frame.width, carousel.frame.size.height))
            view.backgroundColor = UIColor.lightGrayColor()
            
            var swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "presentMenu")
            swipeRecognizer.direction = .Up
            view.addGestureRecognizer(swipeRecognizer)

            
            var thirdScreenWidth = self.view.frame.width / 3
            
            truckLogo = UIImageView(image: UIImage(named: "wickedUrbainGrill.jpg"))
            truckLogo.contentMode = .ScaleAspectFit
            truckLogo.frame = CGRectMake(padding, padding, thirdScreenWidth - padding, view.frame.size.height - (2 * padding))
            
            truckNameLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(truckLogo.frame) + (2*padding), padding, thirdScreenWidth * 2, 25))
            truckNameLabel.backgroundColor = UIColor.clearColor()
            truckNameLabel.textAlignment = .Left
            truckNameLabel.font = truckNameLabel.font.fontWithSize(18)
            truckNameLabel.tag = 1
            
            truckDetailsLabel = UILabel(frame: CGRectMake(CGRectGetMaxX(truckLogo.frame) + (2*padding), CGRectGetMaxY(truckNameLabel.frame) + padding, thirdScreenWidth * 2, 25))
            truckDetailsLabel.backgroundColor = UIColor.clearColor()
            truckDetailsLabel.textAlignment = .Left
            truckDetailsLabel.font = UIFont.italicSystemFontOfSize(14)
            truckDetailsLabel.tag = 2
            
            view.addSubview(truckLogo)
            view.addSubview(truckNameLabel)
            view.addSubview(truckDetailsLabel)
        }
        else
        {
            //get a reference to the label in the recycled view
            truckNameLabel = view.viewWithTag(1) as UILabel!
            truckDetailsLabel = view.viewWithTag(2) as UILabel!
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        truckNameLabel.text = activeTrucks[index].name
        truckDetailsLabel.text = activeTrucks[index].id
        
        return view
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
        var annotations = mapClusterController.annotations.allObjects
        
        if (annotations.count > 0) {
            let curIndex = truckCarousel.currentItemIndex
            centerMapOverCoordinate(annotations[curIndex].coordinate)
        }
    }
    
    // MARK: - iCarouselDelegate Methods
    
//    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
//    {
//        if (option == .Spacing) {
//            return value * 1.1
//        }
//        return value
//    }
    
    // MARK: - UIVieControllerTransitioningDelegate Methods
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionManager.transitionTo = .MODAL;
        return self.transitionManager;
    }
    
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionManager.transitionTo = .INITIAL;
        return self.transitionManager;
    }

    // MARK: - Test Methods to be removed
    
    func getTestData() -> [TruckLocationAnnotation] {
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
        
        var points = [TruckLocationAnnotation]()

        for var i = 0; i < data.count; i+=2 {
            var location = CLLocationCoordinate2D(latitude: data[i], longitude: data[i+1])
            var a = TruckLocationAnnotation(location: location, index: i)
            points.append(a)
        }
        
        return points
    }
}