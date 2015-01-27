//
//  MapViewController.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 10/7/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import MapKit
import Realm

class MapViewController: UIViewController,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    CCHMapClusterControllerDelegate,
    iCarouselDataSource,
    iCarouselDelegate,
    SearchCompletionProtocol,
    UISearchBarDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var searchDelegate: SearchDelegate<MapViewController>?
    
    let deltaDegrees = 0.02
    var locationManager: CLLocationManager!
    var loginViewController: LoginViewController?
    var mapClusterController: CCHMapClusterController!
    var truckCarousel: iCarousel!
    var count: Int = 0
    var showingMenu = false
    var originalTrucks = [RTruck]()
    var activeTrucks: [RTruck] = [RTruck]() {
        didSet {
            self.truckCarousel.layer.shadowOpacity = self.activeTrucks.count > 0 ? 0.2 : 0.0
        }
    }
    
    let trucksManager = TrucksManager()
    let menuManager = MenuManager()
    
    var initialTouchY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var muncherImage = UIImage(named: "muncherTM")
        var muncherImageView = UIImageView(image: muncherImage)
        muncherImageView.frame = CGRectMake(0, 0, 40, 40)
        muncherImageView.contentMode = UIViewContentMode.ScaleAspectFit
        navigationItem.titleView = muncherImageView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\u{f090}", style: .Plain, target: self, action: "login")
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 23.0)!], forState: .Normal)
        
        searchDelegate = SearchDelegate(completionDelegate: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "showSearchBar")
        searchDelegate?.searchBar.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateCarouselWithTruckMenus()
        
        initLocationManager()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.startUpdatingLocation()
            mapClusterControllerSetup()
            truckCarouselSetup()
        }
    }
    
    func mapClusterControllerSetup() {
        self.mapView.delegate = self
        
        mapClusterController = CCHMapClusterController(mapView: self.mapView)
        mapClusterController.delegate = self
        mapClusterController.cellSize = 60
        mapClusterController.marginFactor = 0.5
        mapClusterController.maxZoomLevelForClustering = 25
        mapClusterController.minUniqueLocationsForClustering = 2
    }
    
    func truckCarouselSetup() {
        if truckCarousel != nil {
            truckCarousel.removeFromSuperview()
            truckCarousel = nil
        }
        truckCarousel = iCarousel(frame: CGRectMake(0.0, mapView.frame.maxY - 100.0, mapView.frame.size.width, mapView.frame.size.height - 20.0))
        truckCarousel.type = .Linear
        truckCarousel.delegate = self
        truckCarousel.dataSource = self
        truckCarousel.pagingEnabled = true
        truckCarousel.currentItemIndex = 0
        truckCarousel.bounces = true
        truckCarousel.layer.masksToBounds = false
        truckCarousel.layer.shadowColor = UIColor.blackColor().CGColor
        truckCarousel.layer.shadowOffset = CGSizeMake(0.0, -3.0)
        truckCarousel.layer.shadowOpacity = 0.0
        truckCarousel.layer.shadowPath = UIBezierPath(rect: truckCarousel.bounds).CGPath
        
        view.addSubview(truckCarousel)
        attachGestureRecognizerToCarousel()
    }
    
    func showSearchBar() {
        originalTrucks = [RTruck](activeTrucks)
        searchDelegate?.showSearchBar()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchDelegate?.searchBarSearchButtonClicked(searchBar)
            return
        })
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchDelegate?.searchBarCancelButtonClicked(searchBar)
            return
        })
    }
    
    func updateCarouselWithTruckMenus() {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            menuManager.getFullMenus(atLatitude: 0, longitude: 0, includeAvailability: true, success: { (response) -> () in
                self.trucksManager.getTruckProfiles(atLatitude: 0, longitude: 0, success: { (response) -> () in
                    if self.locationManager != nil {
                        self.updateData()
                    }
                }, error: { (error) -> () in
                        println("error fetching truck profiles \(error)")
                })
            }) { (error) -> () in
                    println("error fetching full menus \(error)")
            }
        }
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
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
        
        if let tappedTruckIndex = truckLocationAnnotation?.index {
            truckCarousel.currentItemIndex = tappedTruckIndex
            truckCarousel.scrollToItemAtIndex(tappedTruckIndex, animated: true)
            
        }
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
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            locationManager.startUpdatingLocation()
            mapClusterControllerSetup()
            truckCarouselSetup()
            updateCarouselWithTruckMenus()
            zoomToCurrentLocation()
        }
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
        let ruser = RUser.objectsWhere("sessionToken = %@", NSUserDefaults.standardUserDefaults().valueForKey("sessionToken") as String).firstObject() as RUser
        
        ///////////////////////////////////////////////////////////////////////////
        // TODO remove all of this once the realm issue is fixed
        // TODO be sure to remove the `import Realm` statement as well once this is removed
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        ruser.truckIds.addObject(RString.initFromString("4405c266-5093-4c82-9edc-a23c322b6e2e"))
        realm.commitWriteTransaction()
        ///////////////////////////////////////////////////////////////////////////
        let truck = RTruck.objectsWhere("id = %@", (ruser.truckIds.objectAtIndex(0) as RString).value).firstObject() as RTruck
        let vendorMapVC = VendorMapViewController(nibName: "VendorMapViewController", bundle: nil, truck: truck)
        navigationController?.pushViewController(vendorMapVC, animated: true)
    }
    
    func updateData() {
        let location = locationManager.location
        if location != nil {
            let lat =  locationManager.location.coordinate.latitude
            let long = locationManager.location.coordinate.longitude
            trucksManager.getActiveTrucks(atLatitude: lat, longitude: long, withSearchQuery: String(), success: { (response) -> () in
                self.activeTrucks = self.orderTrucksByDistanceFromCurrentLocation(response as [RTruck])
                self.updateMapWithActiveTrucks()
                self.truckCarousel.reloadData()
                }) { (error) -> () in
                    var alert = UIAlertController(title: "Oops!", message: "We weren't able to load truck locations", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func orderTrucksByDistanceFromCurrentLocation(trucks: [RTruck]) -> [RTruck] {
        for truck in trucks {
            let distance = locationManager.location.distanceFromLocation(CLLocation(latitude: truck.latitude, longitude: truck.longitude))
            truck.distanceFromMe = (Double)(distance/1609.344)
        }
        
        return trucks.sorted({ $0.distanceFromMe < $1.distanceFromMe })
    }
    
    func updateMapWithActiveTrucks() {
        mapView.removeAnnotations(mapView.annotations)

        var annotations = [TruckLocationAnnotation]()
        
        for i in 0..<activeTrucks.count {
            var location = CLLocationCoordinate2D(latitude: activeTrucks[i].latitude, longitude: activeTrucks[i].longitude)
            var a = TruckLocationAnnotation(location: location, index: i, truckId: activeTrucks[i].id)
            annotations.append(a)
        }
        
        mapClusterControllerSetup()
        mapClusterController.addAnnotations(annotations, withCompletionHandler: nil)
    }
    
    // MARK: - iCarouselDataSource Methods
    
    func attachGestureRecognizerToCarousel() {
        truckCarousel.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePan:"))
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let bottom = mapView.frame.maxY - 100.0
        let top: CGFloat = 20.0
        let touchLocationOnScreen = recognizer.locationInView(view)
        
        if recognizer.state == .Began {
            initialTouchY = recognizer.locationInView(truckCarousel).y
        }
        
        let y = min(max(touchLocationOnScreen.y - initialTouchY, top), bottom)
        var frame = truckCarousel.frame
        frame.origin.y = y
        truckCarousel.frame = frame
        
        let percentage = (bottom-y)/(bottom-top)
        
        // fade out the nav bar items as we pull up the menu
        navigationItem.titleView?.alpha = 1-percentage
        let color = (UINavigationBar.appearance().titleTextAttributes![NSForegroundColorAttributeName] as UIColor).colorWithAlphaComponent(1-percentage)
        navigationItem.leftBarButtonItem?.tintColor = color
        navigationItem.rightBarButtonItem?.tintColor = color
        
        // proportionally move the navbar out of sight/back down, but keep the status bar
        var navbarFrame = navigationController!.navigationBar.frame
        navbarFrame.origin.y = min(max(top - percentage*navbarFrame.size.height, top - navbarFrame.size.height), top)
        navigationController?.navigationBar.frame = navbarFrame
        
        let primaryColor = UIColor(rgba: (activeTrucks[truckCarousel.currentItemIndex] as RTruck).primaryColor)
        let currentView = truckCarousel.itemViewAtIndex(truckCarousel.currentItemIndex) as TruckDetailView
        currentView.updateViewWithColor(carouselBackground.transformToColor(primaryColor, withPercentage: percentage))
        
        if recognizer.state == .Ended {
            // if we ended the pan, based on the velocity, we need to snap the menu and nav bar to their final positions as well as fading nav bar items
            let velocity = recognizer.velocityInView(view)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                frame.origin.y = velocity.y > 0 ? bottom : top
                self.truckCarousel.frame = frame
                navbarFrame.origin.y = velocity.y > 0 ? top : top-navbarFrame.size.height
                self.navigationController?.navigationBar.frame = navbarFrame
                self.showingMenu = frame.origin.y == top
                
                self.navigationItem.titleView?.alpha = self.showingMenu ? 0.0 : 1.0
                self.navigationItem.leftBarButtonItem?.tintColor = color.colorWithAlphaComponent(self.showingMenu ? 0.0 : 1.0)
                self.navigationItem.rightBarButtonItem?.tintColor = color.colorWithAlphaComponent(self.showingMenu ? 0.0 : 1.0)
                
                currentView.updateViewWithColor(self.showingMenu ? primaryColor : carouselBackground)

            }, completion: { (completed) -> Void in
                self.truckCarousel.reloadData()
            })
            initialTouchY = 0
        }
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
            view.frame = CGRectMake(0.0, 0.0, truckCarousel.frame.size.width, truckCarousel.frame.size.height)
        }
        (view as TruckDetailView).updateViewWithTruck(activeTrucks[index], showingMenu: showingMenu)

        return view
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
        for i in 0..<activeTrucks.count {
            let currentCarouselTruckId = (activeTrucks[carousel.currentItemIndex] as RTruck).id
            let someTruck = activeTrucks[i] as RTruck
            if someTruck.id == currentCarouselTruckId {
                let coord = CLLocationCoordinate2D(latitude: someTruck.latitude, longitude: someTruck.longitude)
                centerMapOverCoordinate(coord)
            }
        }
    }
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        if !showingMenu {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: { () -> Void in
                self.truckCarousel.frame = CGRectMake(0.0, self.mapView.frame.maxY - 130.0, self.mapView.frame.size.width, self.mapView.frame.size.height - 20.0)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.truckCarousel.frame = CGRectMake(0.0, self.mapView.frame.maxY - 100.0, self.mapView.frame.size.width, self.mapView.frame.size.height - 20.0)
                }, completion: nil)
            })
        }
    }
    
    // MARK: - SearchCompletionProtocol
    
    func searchSuccessful(results: [RTruck]) {
        activeTrucks = [RTruck](results)
        updateMapWithActiveTrucks()
        truckCarousel.reloadData()
        truckCarousel.scrollToItemAtIndex(0, animated: false)
    }
    
    func searchCancelled() {
        activeTrucks = [RTruck](originalTrucks)
        originalTrucks = [RTruck]()
        updateMapWithActiveTrucks()
        truckCarousel.reloadData()
        truckCarousel.scrollToItemAtIndex(0, animated: false)
    }
}