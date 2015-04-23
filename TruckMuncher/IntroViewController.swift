//
//  IntroViewController.swift
//  TruckMuncher
//
//  Created by ault on 4/21/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {

    let numberOfPages: CGFloat = 9
    var isAtEnd = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    lazy var lblMarketing = UILabel()
    lazy var lblNearbyTrucks = UILabel()
    lazy var lblAllTrucks = UILabel()
    lazy var lblSettings = UILabel()
    lazy var lblTruckDetails = UILabel()
    lazy var lblVendor = UILabel()
    
    lazy var imgLogo = UIImageView()
    lazy var imgMapView = UIImageView()
    lazy var imgSettings = UIImageView()
    lazy var imgVendorMapView = UIImageView()
    lazy var imgPullDown = UIImageView()
    lazy var imgMenuDetail = UIImageView()
    
    let animator = IFTTTAnimator()
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = UIScreen.mainScreen().bounds.width
        height = UIScreen.mainScreen().bounds.height
        
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        scrollView.contentSize = CGSizeMake(numberOfPages * width, height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.accessibilityLabel = "TruckMuncher"
        scrollView.accessibilityIdentifier = "TruckMuncher"
        
        placeViews()
        configureAnimation()
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
        lblMarketing.numberOfLines = 0
        lblMarketing.textAlignment = .Center
        lblMarketing.text = "TruckMuncher is Milwaukee's ultimate food truck hub! Whether you're searching for somewhere new to grab a bite or just want to see where your favorite truck is serving today, TruckMuncher will help you make the most of your lunch hour."
        let marketingSize = lblMarketing.sizeThatFits(CGSizeMake(width, height))
        lblMarketing.frame = CGRectMake(timeForPage(1), height-80-marketingSize.height, width, marketingSize.height)
        scrollView.addSubview(lblMarketing)
        
        imgLogo = UIImageView(image: UIImage(named: "intro_logo"))
        var originalWidth = imgLogo.frame.size.width
        let logoWidth = width * 0.5
        var newHeight = logoWidth/originalWidth*imgLogo.frame.size.height
        imgLogo.frame = CGRectMake(timeForPage(1) + (width-logoWidth)/2, (lblMarketing.frame.origin.y-newHeight)/2, logoWidth, newHeight)
        scrollView.addSubview(imgLogo)
        
        lblNearbyTrucks = UILabel()
        lblNearbyTrucks.numberOfLines = 0
        lblNearbyTrucks.textAlignment = .Center
        lblNearbyTrucks.text = "You can see food trucks nearby that are currently serving on the map, search for a truck..."
        let nearbySize = lblNearbyTrucks.sizeThatFits(CGSizeMake(width, height))
        lblNearbyTrucks.frame = CGRectMake(timeForPage(2), 20, width, nearbySize.height)
        scrollView.addSubview(lblNearbyTrucks)
        
        lblAllTrucks = UILabel()
        lblAllTrucks.numberOfLines = 0
        lblAllTrucks.textAlignment = .Center
        lblAllTrucks.text = "...or view a list of all trucks."
        let allSize = lblAllTrucks.sizeThatFits(CGSizeMake(width, height))
        lblAllTrucks.frame = CGRectMake(timeForPage(3), 20, width, allSize.height)
        scrollView.addSubview(lblAllTrucks)
        
        imgMapView = UIImageView(image: UIImage(named: "intro_map"))
        originalWidth = imgMapView.frame.size.width
        let newWidth = width * 0.8
        newHeight = newWidth/originalWidth*imgMapView.frame.size.height
        imgMapView.frame = CGRectMake(timeForPage(2) + (width-newWidth)/2, 40 + max(nearbySize.height, allSize.height), newWidth, newHeight)
        scrollView.addSubview(imgMapView)
        
        lblSettings = UILabel()
        lblSettings.numberOfLines = 0
        lblSettings.textAlignment = .Center
        lblSettings.text = "Once you login to keep track of your favorite trucks, tap here to access your settings"
        let settingsSize = lblSettings.sizeThatFits(CGSizeMake(width, height))
        lblSettings.frame = CGRectMake(timeForPage(4), 20, width, settingsSize.height)
        scrollView.addSubview(lblSettings)
        
        imgSettings = UIImageView(image: UIImage(named: "intro_settings"))
        originalWidth = imgSettings.frame.size.width
        newHeight = newWidth/originalWidth*imgSettings.frame.size.height
        imgSettings.frame = CGRectMake(timeForPage(5) + (width-newWidth)/2, 40 + settingsSize.height, newWidth, newHeight)
        scrollView.addSubview(imgSettings)
        
        lblTruckDetails = UILabel()
        lblTruckDetails.numberOfLines = 0
        lblTruckDetails.textAlignment = .Center
        lblTruckDetails.text = "Pulling up on the truck's information allows you to view a truck's location, its distance from you, and even its menu and prices!"
        let truckSize = lblTruckDetails.sizeThatFits(CGSizeMake(width, height))
        lblTruckDetails.frame = CGRectMake(timeForPage(6), 20, width, truckSize.height)
        scrollView.addSubview(lblTruckDetails)
        
        imgMenuDetail = UIImageView(image: UIImage(named: "intro_menu"))
        originalWidth = imgMenuDetail.frame.size.width
        newHeight = newWidth/originalWidth*imgMenuDetail.frame.size.height
        imgMenuDetail.frame = CGRectMake(timeForPage(6) + (width-newWidth)/2, CGRectGetMaxY(imgMapView.frame), newWidth, newHeight) // one page early
        scrollView.addSubview(imgMenuDetail)
        
        lblVendor = UILabel()
        lblVendor.numberOfLines = 0
        lblVendor.textAlignment = .Center
        lblVendor.text = "Own a truck? Start reporting your location by going into serving mode! If you own more than one truck, pull down on your truck's name to choose which one you want to manage"
        let vendorSize = lblVendor.sizeThatFits(CGSizeMake(width, height))
        lblVendor.frame = CGRectMake(timeForPage(8), 20, width, vendorSize.height)
        scrollView.addSubview(lblVendor)
        
        imgVendorMapView = UIImageView(image: UIImage(named: "intro_vendor_map"))
        originalWidth = imgVendorMapView.frame.size.width
        newHeight = newWidth/originalWidth*imgVendorMapView.frame.size.height
        imgVendorMapView.frame = CGRectMake(timeForPage(8) + (width-newWidth)/2, 40 + vendorSize.height, newWidth, newHeight)
        scrollView.addSubview(imgVendorMapView)
        
        imgPullDown = UIImageView(image: UIImage(named: "intro_pull_down"))
        originalWidth = imgPullDown.frame.size.width
        newHeight = newWidth/originalWidth*imgPullDown.frame.size.height
        imgPullDown.frame = CGRectMake(timeForPage(9) + (width-newWidth)/2, 104 + vendorSize.height, newWidth, newHeight)
        scrollView.addSubview(imgPullDown)
        
        view.bringSubviewToFront(pageControl)
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
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(7)), andFrame: CGRectOffset(imgMenuDetail.frame, width, -imgMapView.frame.size.height+20)))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(8)), andFrame: CGRectOffset(imgMenuDetail.frame, width, -imgMapView.frame.size.height+20)))
        imgMenuFrameAnimation.addKeyFrame(IFTTTAnimationKeyFrame(time: NSInteger(timeForPage(9)), andFrame: CGRectOffset(imgMenuDetail.frame, width, -imgMapView.frame.size.height+20)))
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
        
        /*CGFloat dy = 240;
        
        // apply a 3D zoom animation to the first label
        IFTTTTransform3DAnimation * labelTransform = [IFTTTTransform3DAnimation animationWithView:self.firstLabel];
        IFTTTTransform3D *tt1 = [IFTTTTransform3D transformWithM34:0.03f];
        IFTTTTransform3D *tt2 = [IFTTTTransform3D transformWithM34:0.3f];
        tt2.rotate = (IFTTTTransform3DRotate){ -(CGFloat)(M_PI), 1, 0, 0 };
        tt2.translate = (IFTTTTransform3DTranslate){ 0, 0, 50 };
        tt2.scale = (IFTTTTransform3DScale){ 1.f, 2.f, 1.f };
        [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(0)
        andAlpha:1.0f]];
        [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1)
        andTransform3D:tt1]];
        [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1.5)
        andTransform3D:tt2]];
        [labelTransform addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1.5) + 1
        andAlpha:0.0f]];
        [self.animator addAnimation:labelTransform];
        
        // let's animate the wordmark
        IFTTTFrameAnimation *wordmarkFrameAnimation = [IFTTTFrameAnimation animationWithView:self.wordmark];
        [self.animator addAnimation:wordmarkFrameAnimation];
        
        [wordmarkFrameAnimation addKeyFrames:@[
        ({
        IFTTTAnimationKeyFrame *keyFrame = [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:CGRectOffset(self.wordmark.frame, 200, 0)];
        keyFrame.easingFunction = IFTTTEasingFunctionEaseInQuart;
        keyFrame;
        }),
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:self.wordmark.frame],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.wordmark.frame, self.view.frame.size.width, dy)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andFrame:CGRectOffset(self.wordmark.frame, 0, dy)],
        ]];
        
        // Rotate a full circle from page 2 to 3
        IFTTTAngleAnimation *wordmarkRotationAnimation = [IFTTTAngleAnimation animationWithView:self.wordmark];
        [self.animator addAnimation:wordmarkRotationAnimation];
        [wordmarkRotationAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAngle:0.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAngle:(CGFloat)(2 * M_PI)],
        ]];
        
        // now, we animate the unicorn
        IFTTTFrameAnimation *unicornFrameAnimation = [IFTTTFrameAnimation animationWithView:self.unicorn];
        [self.animator addAnimation:unicornFrameAnimation];
        
        CGFloat ds = 50;
        
        // move down and to the right, and shrink between pages 2 and 3
        [unicornFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:self.unicorn.frame]];
        [unicornFrameAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3)
        andFrame:CGRectOffset(CGRectInset(self.unicorn.frame, ds, ds), timeForPage(2), dy)]];
        // fade the unicorn in on page 2 and out on page 4
        IFTTTAlphaAnimation *unicornAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.unicorn];
        [self.animator addAnimation:unicornAlphaAnimation];
        
        [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAlpha:0.0f]];
        [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:1.0f]];
        [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:1.0f]];
        [unicornAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:0.0f]];
        
        // Fade out the label by dragging on the last page
        IFTTTAlphaAnimation *labelAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.lastLabel];
        [labelAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andAlpha:1.0f]];
        [labelAlphaAnimation addKeyFrame:[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4.35f) andAlpha:0.0f]];
        [self.animator addAnimation:labelAlphaAnimation];*/
    }
    
    func IFTTTMaxContentOffsetXForScrollView(scrollView: UIScrollView) -> CGFloat {
        return scrollView.contentSize.width + scrollView.contentInset.right - CGRectGetWidth(scrollView.bounds)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        animator.animate(NSInteger(scrollView.contentOffset.x))
        
        isAtEnd = scrollView.contentOffset.x >= IFTTTMaxContentOffsetXForScrollView(scrollView)
        
        if isAtEnd {
            println("Scrolled to end of scrollview!")
        }
        pageControl.currentPage = lroundf(Float(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width))
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAtEnd {
            println("Ended dragging at end of scrollview!")
        }
    }
    
}
