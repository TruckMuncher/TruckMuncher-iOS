//
//  IntroViewController.swift
//  TruckMuncher
//
//  Created by ault on 4/21/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

protocol IntroDelegate {
    func keepNavBarHidden() -> Bool
}

class IntroViewController: UIViewController, UIScrollViewDelegate {

    let numberOfPages: CGFloat = 10
    var isAtEnd = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    lazy var lblMarketing = UILabel()
    lazy var lblNearbyTrucks = UILabel()
    lazy var lblAllTrucks = UILabel()
    lazy var lblSettings = UILabel()
    lazy var lblTruckDetails = UILabel()
    lazy var lblVendor = UILabel()
    lazy var lblOutro = UILabel()
    
    lazy var imgLogo = UIImageView()
    lazy var imgMapView = UIImageView()
    lazy var imgSettings = UIImageView()
    lazy var imgVendorMapView = UIImageView()
    lazy var imgPullDown = UIImageView()
    lazy var imgMenuDetail = UIImageView()
    
    lazy var btnIndicator = UIButton()
    lazy var btnDone = UIButton()
    
    let animator = IFTTTAnimator()
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    var scale: CGFloat = 0
    var vendorScale: CGFloat = 0
    
    var delegate: IntroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        println("\(UIScreen.mainScreen().scale)")
        
        width = UIScreen.mainScreen().bounds.width
        height = UIScreen.mainScreen().bounds.height
        
        pageControl.numberOfPages = Int(numberOfPages)
        
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        scrollView.contentSize = CGSizeMake(numberOfPages * width, height)
        scrollView.accessibilityLabel = "TruckMuncher"
        scrollView.accessibilityIdentifier = "TruckMuncher"
        
        placeViews()
        configureAnimation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = delegate?.keepNavBarHidden() ?? false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timeForPage(page: CGFloat) -> CGFloat {
        return width * (page - 1)
    }
    
    func placeViews() {
        lblMarketing = UILabel()
        lblMarketing.backgroundColor = UIColor.whiteColor()
        lblMarketing.numberOfLines = 0
        lblMarketing.textAlignment = .Center
        lblMarketing.text = "TruckMuncher is Milwaukee's ultimate food truck hub! Whether you're searching for somewhere new to grab a bite or just want to see where your favorite truck is serving today, TruckMuncher will help you make the most of your lunch hour."
        let marketingSize = lblMarketing.sizeThatFits(CGSizeMake(width - 40, height))
        lblMarketing.frame = CGRectMake(timeForPage(1) + 20, height-80-marketingSize.height, width - 40, marketingSize.height)
        scrollView.addSubview(lblMarketing)
        
        imgLogo = UIImageView(image: UIImage(named: "intro_logo"))
        var originalHeight = imgLogo.frame.size.height
        let logoHeight = width * 0.5
        var newWidth = logoHeight/originalHeight*imgLogo.frame.size.width
        imgLogo.frame = CGRectMake(timeForPage(1) + (width-newWidth)/2, (lblMarketing.frame.origin.y-logoHeight)/2, newWidth, logoHeight)
        scrollView.addSubview(imgLogo)
        
        lblNearbyTrucks = UILabel()
        lblNearbyTrucks.backgroundColor = UIColor.whiteColor()
        lblNearbyTrucks.numberOfLines = 0
        lblNearbyTrucks.textAlignment = .Center
        lblNearbyTrucks.text = "You can see food trucks nearby on the map that are currently serving, search for a truck, ..."
        let nearbySize = lblNearbyTrucks.sizeThatFits(CGSizeMake(width - 40, height))
        lblNearbyTrucks.frame = CGRectMake(timeForPage(2) + 20, 20, width - 40, nearbySize.height)
        scrollView.addSubview(lblNearbyTrucks)
        
        lblAllTrucks = UILabel()
        lblAllTrucks.backgroundColor = UIColor.whiteColor()
        lblAllTrucks.numberOfLines = 0
        lblAllTrucks.textAlignment = .Center
        lblAllTrucks.text = "...or view a list of all trucks."
        let allSize = lblAllTrucks.sizeThatFits(CGSizeMake(width - 40, height))
        lblAllTrucks.frame = CGRectMake(timeForPage(3) + 20, 20, width - 40, allSize.height)
        scrollView.addSubview(lblAllTrucks)
        
        btnIndicator = UIButton(frame: CGRectMake(0, height, 100, 100))
        btnIndicator.titleLabel?.font = UIFont(name: "FontAwesome", size: 60)
        btnIndicator.setTitle("\u{f1db}", forState: .Normal)
        btnIndicator.backgroundColor = UIColor.clearColor()
        btnIndicator.setTitleColor(UIColor(rgba: "#009688"), forState: .Normal)
        btnIndicator.setTitleColor(UIColor(rgba: "#009688").colorWithAlphaComponent(0.5), forState: .Highlighted)
        btnIndicator.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
        btnIndicator.layer.shadowColor = UIColor(rgba: "#009688").CGColor
        btnIndicator.layer.shadowOpacity = 1.0
        btnIndicator.layer.shadowRadius = 5.0
        scrollView.addSubview(btnIndicator)
        
        lblSettings = UILabel()
        lblSettings.backgroundColor = UIColor.whiteColor()
        lblSettings.numberOfLines = 0
        lblSettings.textAlignment = .Center
        lblSettings.text = "Once you login to keep track of your favorite trucks, tap here to access your settings"
        let settingsSize = lblSettings.sizeThatFits(CGSizeMake(width - 40, height))
        lblSettings.frame = CGRectMake(timeForPage(4) + 20, 20, width - 40, settingsSize.height)
        scrollView.addSubview(lblSettings)
        
        lblTruckDetails = UILabel()
        lblTruckDetails.backgroundColor = UIColor.whiteColor()
        lblTruckDetails.numberOfLines = 0
        lblTruckDetails.textAlignment = .Center
        lblTruckDetails.text = "Pulling up on the truck's information allows you to view a truck's location, its distance from you, and even its menu and prices!"
        let truckSize = lblTruckDetails.sizeThatFits(CGSizeMake(width - 40, height))
        lblTruckDetails.frame = CGRectMake(timeForPage(6) + 20, 20, width - 40, truckSize.height)
        scrollView.addSubview(lblTruckDetails)
        
        imgMapView = UIImageView(image: UIImage(named: "intro_map"))
        originalHeight = imgMapView.frame.size.height
        let maxTextHeight = max(nearbySize.height, allSize.height, settingsSize.height, truckSize.height)
        var newHeight = height - pageControl.frame.size.height - 60 - maxTextHeight
        newWidth = newHeight/originalHeight*imgMapView.frame.size.width
        scale = newHeight/originalHeight * min(UIScreen.mainScreen().scale, 2)
        imgMapView.frame = CGRectMake(timeForPage(2) + (width-newWidth)/2, 40 + maxTextHeight, newWidth, newHeight)
        scrollView.addSubview(imgMapView)
        
        imgSettings = UIImageView(image: UIImage(named: "intro_settings"))
        originalHeight = imgSettings.frame.size.height
        newHeight = newWidth/imgSettings.frame.size.width*imgSettings.frame.size.height
        imgSettings.frame = CGRectMake(timeForPage(4) + (width-newWidth)/2, -newHeight, newWidth, newHeight) // one page early
        scrollView.addSubview(imgSettings)
        
        imgMenuDetail = UIImageView(image: UIImage(named: "intro_menu"))
        originalHeight = imgMenuDetail.frame.size.height
        newHeight = newWidth/imgMenuDetail.frame.size.width*imgMenuDetail.frame.size.height
        imgMenuDetail.frame = CGRectMake(timeForPage(6) + (width-newWidth)/2, CGRectGetMaxY(imgMapView.frame), newWidth, newHeight) // one page early
        scrollView.addSubview(imgMenuDetail)
        
        lblVendor = UILabel()
        lblVendor.backgroundColor = UIColor.whiteColor()
        lblVendor.numberOfLines = 0
        lblVendor.textAlignment = .Center
        lblVendor.text = "Own a truck? Start reporting your location by going into serving mode! If you own more than one truck, pull down on your truck's name to choose which one you want to manage"
        let vendorSize = lblVendor.sizeThatFits(CGSizeMake(width - 40, height))
        lblVendor.frame = CGRectMake(timeForPage(8) + 20, 20, width - 40, vendorSize.height)
        scrollView.addSubview(lblVendor)
        
        imgVendorMapView = UIImageView(image: UIImage(named: "intro_vendor_map"))
        originalHeight = imgVendorMapView.frame.size.height
        newHeight = height - pageControl.frame.size.height - 60 - vendorSize.height
        newWidth = newHeight/originalHeight*imgVendorMapView.frame.size.width
        vendorScale = newHeight/originalHeight * min(UIScreen.mainScreen().scale, 2)
        imgVendorMapView.frame = CGRectMake(timeForPage(8) + (width-newWidth)/2, 40 + vendorSize.height, newWidth, newHeight)
        scrollView.addSubview(imgVendorMapView)
        
        imgPullDown = UIImageView(image: UIImage(named: "intro_pull_down"))
        originalHeight = imgPullDown.frame.size.height
        newHeight = newWidth/imgPullDown.frame.size.width*imgPullDown.frame.size.height
        imgPullDown.frame = CGRectMake(timeForPage(8) + (width-newWidth)/2, -newHeight, newWidth, newHeight) // one page early
        scrollView.addSubview(imgPullDown)
        
        lblOutro = UILabel()
        lblOutro.backgroundColor = UIColor.whiteColor()
        lblOutro.numberOfLines = 0
        lblOutro.textAlignment = .Center
        lblOutro.text = "You're ready to start using TruckMuncher!"
        let outroSize = lblOutro.sizeThatFits(CGSizeMake(width - 40, height))
        lblOutro.frame = CGRectMake(timeForPage(10) + 20, (height-outroSize.height)/2 - 40, width - 40, outroSize.height)
        scrollView.addSubview(lblOutro)
        
        btnDone = UIButton(frame: CGRectMake(timeForPage(10) + (width - 250)/2, CGRectGetMaxY(lblOutro.frame) + 40, 250, 50))
        btnDone.setTitle("Take me to the app!", forState: .Normal)
        btnDone.backgroundColor = UIColor(rgba: "#009688")
        btnDone.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnDone.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        btnDone.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
        scrollView.addSubview(btnDone)
        
        scrollView.bringSubviewToFront(lblVendor)
        scrollView.bringSubviewToFront(lblSettings)
        scrollView.bringSubviewToFront(pageControl)
        scrollView.bringSubviewToFront(btnIndicator)
    }
    
    func configureAnimation() {
        let imgMapFrameAnimation = IFTTTFrameAnimation(view: imgMapView)
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: imgMapView.frame))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: imgMapView.frame))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: CGRectOffset(imgMapView.frame, width, 0)))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: CGRectOffset(imgMapView.frame, width*2, 0)))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: CGRectOffset(imgMapView.frame, width*3, 0)))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: CGRectOffset(imgMapView.frame, width*4, 0)))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectOffset(imgMapView.frame, width*5, 0)))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectOffset(imgMapView.frame, width*5, 0)))
        imgMapFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(imgMapView.frame, width*5, 0)))
        animator.addAnimation(imgMapFrameAnimation)
        
        let lblSettingsFrameAnimation = IFTTTFrameAnimation(view: lblSettings)
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: lblSettings.frame))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: lblSettings.frame))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: lblSettings.frame))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: lblSettings.frame))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: CGRectOffset(lblSettings.frame, width, 0)))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: CGRectOffset(lblSettings.frame, width, 0)))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectOffset(lblSettings.frame, width, 0)))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectOffset(lblSettings.frame, width, 0)))
        lblSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(lblSettings.frame, width, 0)))
        animator.addAnimation(lblSettingsFrameAnimation)
        
        let imgSettingsFrameAnimation = IFTTTFrameAnimation(view: imgSettings)
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: imgSettings.frame))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: imgSettings.frame))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: imgSettings.frame))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: imgSettings.frame))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: CGRectMake(imgSettings.frame.origin.x + width, imgMapView.frame.origin.y + (64 * scale), imgSettings.frame.size.width, imgSettings.frame.size.height)))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: CGRectMake(imgSettings.frame.origin.x + width, imgMapView.frame.origin.y + (64 * scale), imgSettings.frame.size.width, imgSettings.frame.size.height)))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectMake(imgSettings.frame.origin.x + width, imgMapView.frame.origin.y + (64 * scale), imgSettings.frame.size.width, imgSettings.frame.size.height)))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectMake(imgSettings.frame.origin.x + width, imgMapView.frame.origin.y + (64 * scale), imgSettings.frame.size.width, imgSettings.frame.size.height)))
        imgSettingsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectMake(imgSettings.frame.origin.x + width, imgMapView.frame.origin.y + (64 * scale), imgSettings.frame.size.width, imgSettings.frame.size.height)))
        animator.addAnimation(imgSettingsFrameAnimation)
        
        let lblTruckDetailsFrameAnimation = IFTTTFrameAnimation(view: lblTruckDetails)
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: lblTruckDetails.frame))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: lblTruckDetails.frame))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: lblTruckDetails.frame))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: lblTruckDetails.frame))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: lblTruckDetails.frame))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: lblTruckDetails.frame))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectOffset(lblTruckDetails.frame, width, 0)))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectOffset(lblTruckDetails.frame, width, 0)))
        lblTruckDetailsFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(lblTruckDetails.frame, width, 0)))
        animator.addAnimation(lblTruckDetailsFrameAnimation)
        
        let lblVendorFrameAnimation = IFTTTFrameAnimation(view: lblVendor)
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: lblVendor.frame))
        lblVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(lblVendor.frame, width, 0)))
        animator.addAnimation(lblVendorFrameAnimation)
        
        let imgMenuFrameAnimation = IFTTTFrameAnimation(view: imgMenuDetail)
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: imgMenuDetail.frame))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: imgMenuDetail.frame))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: imgMenuDetail.frame))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: imgMenuDetail.frame))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: imgMenuDetail.frame))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: imgMenuDetail.frame))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectOffset(imgMenuDetail.frame, width, -imgMapView.frame.size.height+(20 * scale))))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectOffset(imgMenuDetail.frame, width, -imgMapView.frame.size.height+(20 * scale))))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(imgMenuDetail.frame, width, -imgMapView.frame.size.height+(20 * scale))))
        animator.addAnimation(imgMenuFrameAnimation)
        
        let imgMenuAlphaAnimation = IFTTTAlphaAnimation(view: imgMenuDetail)
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andAlpha: 0.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andAlpha: 0.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andAlpha: 0.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andAlpha: 0.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andAlpha: 0.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andAlpha: 0.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6.01)), andAlpha: 1.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andAlpha: 1.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andAlpha: 1.0))
        imgMenuAlphaAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andAlpha: 1.0))
        animator.addAnimation(imgMenuAlphaAnimation)
        
        let imgVendorFrameAnimation = IFTTTFrameAnimation(view: imgVendorMapView)
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: imgVendorMapView.frame))
        imgVendorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(imgVendorMapView.frame, width, 0)))
        animator.addAnimation(imgVendorFrameAnimation)
        
        let imgPullDownFrameAnimation = IFTTTFrameAnimation(view: imgPullDown)
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: imgPullDown.frame))
        imgPullDownFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectMake(imgPullDown.frame.origin.x + width, imgVendorMapView.frame.origin.y + (64 * vendorScale), imgPullDown.frame.size.width, imgPullDown.frame.size.height)))
        animator.addAnimation(imgPullDownFrameAnimation)
        
        let btnIndicatorFrameAnimation = IFTTTFrameAnimation(view: btnIndicator)
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(1)), andFrame: btnIndicator.frame))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(2)), andFrame: CGRectMake(CGRectGetMaxX(imgMapView.frame) - (25 * scale) - 50, imgMapView.frame.origin.y - 50 + (42 * scale), 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(3)), andFrame: CGRectMake(CGRectGetMaxX(imgMapView.frame) + width - (68 * scale) - 50, imgMapView.frame.origin.y - 50 + (42 * scale), 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(4)), andFrame: CGRectMake(CGRectGetMidX(imgMapView.frame) + width*2 - 50, imgMapView.frame.origin.y + (42 * scale) - 50, 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(5)), andFrame: CGRectMake(CGRectGetMidX(imgMapView.frame) + width*3 - 50, imgMapView.frame.origin.y + (42 * scale) - 50, 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(6)), andFrame: CGRectMake(CGRectGetMidX(imgMapView.frame) + width*4 - 50, CGRectGetMaxY(imgMapView.frame) - 100, 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectMake(CGRectGetMidX(imgMapView.frame) + width*5 - 50, CGRectGetMinY(imgMapView.frame), 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectMake(CGRectGetMidX(imgVendorMapView.frame) - 50, imgVendorMapView.frame.origin.y + (42 * scale) - 50, 100, 100)))
        btnIndicatorFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectMake(CGRectGetMidX(imgVendorMapView.frame) + width - 50, imgVendorMapView.frame.origin.y + imgPullDown.frame.size.height, 100, 100)))
        animator.addAnimation(btnIndicatorFrameAnimation)
    }
    
    func done() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kFinishedTutorial)
        NSUserDefaults.standardUserDefaults().synchronize()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func IFTTTMaxContentOffsetXForScrollView(scrollView: UIScrollView) -> CGFloat {
        return scrollView.contentSize.width + scrollView.contentInset.right - CGRectGetWidth(scrollView.bounds)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        animator.animate(NSInteger(scrollView.contentOffset.x))
        
        isAtEnd = scrollView.contentOffset.x >= IFTTTMaxContentOffsetXForScrollView(scrollView)
        
        if isAtEnd {
            //println("Scrolled to end of scrollview!")
        }
        pageControl.currentPage = lroundf(Float(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width))
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAtEnd {
            //println("Ended dragging at end of scrollview!")
        }
    }
    
}
