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
    UIViewControllerTransitioningDelegate,
    UIGestureRecognizerDelegate,
    SearchCompletionProtocol {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchDelegate: SearchDelegate?
    
    var items: [Int] = []
    
    @IBAction func loginAction(sender: AnyObject) { login() }
    
    let deltaDegrees = 0.05
    var locationManager: CLLocationManager!
    var loginViewController: LoginViewController?
    var mapClusterController: CCHMapClusterController!
    var truckCarousel: iCarousel!
    var count: Int = 0
    var showingMenu = false
    var activeTrucks = [RTruck]()
    
    let trucksManager = TrucksManager()
    let menuManager = MenuManager()
    
    var transitionManager = TransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TruckMuncher"
        self.navigationController?.navigationBar.translucent = false

        searchDelegate = SearchDelegate(completionDelegate: self)
        searchBar.delegate = searchDelegate
        
        initLocationManager()
        self.mapView.delegate = self

        mapClusterController = CCHMapClusterController(mapView: self.mapView)
        mapClusterController.delegate = self
        setClusterSettings()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        truckCarousel = iCarousel(frame: CGRectMake(0.0, view.frame.height - 56.0, view.frame.width, view.frame.height))
        truckCarousel.type = .Linear
        truckCarousel.delegate = self
        truckCarousel.dataSource = self
        truckCarousel.pagingEnabled = true
        truckCarousel.currentItemIndex = 0
        truckCarousel.bounces = false
        
        view.addSubview(truckCarousel)
        attachGestureRecognizerToCarousel()
        
        menuManager.getFullMenus(atLatitude: 0, longitude: 0, includeAvailability: true, success: { (response) -> () in
            self.trucksManager.getTruckProfiles(atLatitude: 0, longitude: 0, success: { (response) -> () in
                self.updateData()
            }, error: { (error) -> () in
                println("error fetching truck profiles \(error)")
            })
        }) { (error) -> () in
            println("error fetching full menus \(error)")
        }
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
    
    // MARK: - iCarouselDataSource Methods
    
    func attachGestureRecognizerToCarousel() {

        let swipeSelector: Selector = "handleSwipe:"
        var swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: swipeSelector)
        swipeUpRecognizer.direction = .Up
        truckCarousel.addGestureRecognizer(swipeUpRecognizer);
        
        var swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: swipeSelector)
        swipeDownRecognizer.direction = .Down
        truckCarousel.addGestureRecognizer(swipeDownRecognizer);
    }
    
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        var newRect: CGRect = CGRect.nullRect
        
        if recognizer.direction == .Up {
            let navFrame = self.navigationController?.navigationBar.frame
            newRect = CGRectMake(0.0, CGRectGetMaxY(navFrame!) - 40.0, self.view.frame.width, self.view.frame.height)
            showingMenu = true
        } else if recognizer.direction == .Down {
            newRect = CGRectMake(0.0, self.view.frame.height - 56.0, self.view.frame.width, self.view.frame.height)
            showingMenu = false
        }
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
            self.truckCarousel.frame = newRect
            }, completion: nil)
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return activeTrucks.count
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
    {
        if view == nil {
            var viewArray = NSBundle.mainBundle().loadNibNamed("TruckDetailView", owner: nil, options: nil)
            view = viewArray[0] as TruckDetailView
            view.frame = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            (view as TruckDetailView).updateViewWithTruck(activeTrucks[index])
            
        }
        return view
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
        var annotations = mapClusterController.annotations.allObjects
        
        if (annotations.count > 0) {
            let curIndex = truckCarousel.currentItemIndex
            centerMapOverCoordinate(annotations[curIndex].coordinate)
        }
    }
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        if !showingMenu {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: { () -> Void in
                self.truckCarousel.frame = CGRectMake(0.0, self.view.frame.height - 100.0, self.view.frame.width, self.view.frame.height)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.truckCarousel.frame = CGRectMake(0.0, self.view.frame.height - 56.0, self.view.frame.width, self.view.frame.height)
                }, completion: nil)
            })
            
        }
    }
    
    // MARK: - UIVieControllerTransitioningDelegate Methods
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionManager.transitionTo = .MODAL;
        return self.transitionManager;
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionManager.transitionTo = .INITIAL;
        return self.transitionManager;
    }
    
    // Mark: - UIGestureRecognizerDelegate Methods
    func gestureRecognizer(gestureRecognizer: UISwipeGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UITapGestureRecognizer) -> Bool{
            return true;
    }
    
    // MARK: - SearchCompletionProtocol
    
    func searchSuccessful(results: [RTruck]) {
        println("SEARCH SUCCESS!")
        activeTrucks = results
        updateMapWithActiveTrucks()
        truckCarousel.reloadData()
    }
}