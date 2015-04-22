//
//  IntroViewController.swift
//  TruckMuncher
//
//  Created by ault on 4/21/15.
//  Copyright (c) 2015 TruckMuncher. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {

    let numberOfPages: CGFloat = 5
    var isAtEnd = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    lazy var introLabel1 = UILabel()
    lazy var introLabel2 = UILabel()
    lazy var introLabel3 = UILabel()
    lazy var introLabel4 = UILabel()
    lazy var introLabel5 = UILabel()
    
    lazy var introImage1 = UIImageView()
    lazy var introImage2 = UIImageView()
    lazy var introImage3 = UIImageView()
    lazy var introImage4 = UIImageView()
    lazy var introImage5 = UIImageView()
    
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
        //TruckMuncher is Milwaukee's ultimate food truck hub! Whether you're searching for somewhere new to grab a bite or just want to see where your favorite truck is serving today, TruckMuncher will help you make the most of your lunch hour.
        
        //You can see food trucks nearby that are currently serving, search for a truck, or view a list of all trucks.
        
        //Once you login to keep track of your favorite trucks, tap here to access your settings
        
        //Pulling up on the truck's information allows you to view a truck's location, its distance from you, and even its menu and prices!
        
        //Own a truck? Start reporting your location by going into serving mode! Own multiple trucks? No problem. Pull down the top bar and choose which truck you want to manage
        
        introLabel1 = UILabel()
        introLabel1.numberOfLines = 0
        introLabel1.textAlignment = .Center
        introLabel1.text = "TruckMuncher is Milwaukee's ultimate food truck hub! Whether you're searching for somewhere new to grab a bite or just want to see where your favorite truck is serving today, TruckMuncher will help you make the most of your lunch hour."
        var size = introLabel1.sizeThatFits(CGSizeMake(width, height))
        introLabel1.frame = CGRectMake(timeForPage(1), 20, width, size.height)
        scrollView.addSubview(introLabel1)
        
        introImage1 = UIImageView(image: UIImage(named: "intro1"))
        introImage1.frame = CGRectMake(timeForPage(1), 40 + size.height, width, height - (40 + size.height))
        scrollView.addSubview(introImage1)
        
        introLabel2 = UILabel()
        introLabel2.numberOfLines = 0
        introLabel2.textAlignment = .Center
        introLabel2.text = "You can see food trucks nearby that are currently serving, search for a truck, or view a list of all trucks."
        size = introLabel2.sizeThatFits(CGSizeMake(width, height))
        introLabel2.frame = CGRectMake(timeForPage(2), 20, width, size.height)
        scrollView.addSubview(introLabel2)
        
        introImage2 = UIImageView(image: UIImage(named: "intro2"))
        introImage2.frame = CGRectMake(timeForPage(2), 40 + size.height, width, height - (40 + size.height))
        scrollView.addSubview(introImage2)
        
        introLabel3 = UILabel()
        introLabel3.numberOfLines = 0
        introLabel3.textAlignment = .Center
        introLabel3.text = "Once you login to keep track of your favorite trucks, tap here to access your settings"
        size = introLabel3.sizeThatFits(CGSizeMake(width, height))
        introLabel3.frame = CGRectMake(timeForPage(3), 20, width, size.height)
        scrollView.addSubview(introLabel3)
        
        introImage3 = UIImageView(image: UIImage(named: "intro3"))
        introImage3.frame = CGRectMake(timeForPage(3), 40 + size.height, width, height - (40 + size.height))
        scrollView.addSubview(introImage3)
        
        introLabel4 = UILabel()
        introLabel4.numberOfLines = 0
        introLabel4.textAlignment = .Center
        introLabel4.text = "Pulling up on the truck's information allows you to view a truck's location, its distance from you, and even its menu and prices!"
        size = introLabel4.sizeThatFits(CGSizeMake(width, height))
        introLabel4.frame = CGRectMake(timeForPage(4), 20, width, size.height)
        scrollView.addSubview(introLabel4)
        
        introImage4 = UIImageView(image: UIImage(named: "intro4"))
        introImage4.frame = CGRectMake(timeForPage(4), 40 + size.height, width, height - (40 + size.height))
        scrollView.addSubview(introImage4)
        
        introLabel5 = UILabel()
        introLabel5.numberOfLines = 0
        introLabel5.textAlignment = .Center
        introLabel5.text = "Own a truck? Start reporting your location by going into serving mode! Own multiple trucks? No problem. Pull down the top bar and choose which truck you want to manage"
        size = introLabel5.sizeThatFits(CGSizeMake(width, height))
        introLabel5.frame = CGRectMake(timeForPage(5), 20, width, size.height)
        scrollView.addSubview(introLabel5)
        
        introImage5 = UIImageView(image: UIImage(named: "intro5"))
        introImage5.frame = CGRectMake(timeForPage(5), 40 + size.height, width, height - (40 + size.height))
        scrollView.addSubview(introImage5)
        
        // put a unicorn in the middle of page two, hidden
        /*self.unicorn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Unicorn"]];
        self.unicorn.center = self.view.center;
        self.unicorn.frame = CGRectOffset(
        self.unicorn.frame,
        self.view.frame.size.width,
        -100
        );
        self.unicorn.alpha = 0.0f;
        [self.scrollView addSubview:self.unicorn];
        
        // put a logo on top of it
        self.wordmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IFTTT"]];
        self.wordmark.center = self.view.center;
        self.wordmark.frame = CGRectOffset(
        self.wordmark.frame,
        self.view.frame.size.width,
        -100
        );
        [self.scrollView addSubview:self.wordmark];
        
        self.firstLabel = [[UILabel alloc] init];
        self.firstLabel.text = @"Introducing Jazz Hands";
        [self.firstLabel sizeToFit];
        self.firstLabel.center = self.view.center;
        [self.scrollView addSubview:self.firstLabel];
        
        UILabel *secondPageText = [[UILabel alloc] init];
        secondPageText.text = @"Brought to you by IFTTT";
        [secondPageText sizeToFit];
        secondPageText.center = self.view.center;
        secondPageText.frame = CGRectOffset(secondPageText.frame, timeForPage(2), 180);
        [self.scrollView addSubview:secondPageText];
        
        UILabel *thirdPageText = [[UILabel alloc] init];
        thirdPageText.text = @"Simple keyframe animations";
        [thirdPageText sizeToFit];
        thirdPageText.center = self.view.center;
        thirdPageText.frame = CGRectOffset(thirdPageText.frame, timeForPage(3), -100);
        [self.scrollView addSubview:thirdPageText];
        
        UILabel *fourthPageText = [[UILabel alloc] init];
        fourthPageText.text = @"Optimized for scrolling intros";
        [fourthPageText sizeToFit];
        fourthPageText.center = self.view.center;
        fourthPageText.frame = CGRectOffset(fourthPageText.frame, timeForPage(4), 0);
        [self.scrollView addSubview:fourthPageText];
        
        self.lastLabel = fourthPageText;*/
    }
    
    func configureAnimation() {
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
