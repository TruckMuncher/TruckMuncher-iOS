//
//  TransitionManager.swift
//  TruckMuncher
//
//  Created by Andrew Moore on 12/18/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit

enum TransitionStep : Int {
    case INITIAL = 0
    case MODAL
}

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionTo = TransitionStep.INITIAL
    
    override init() {
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 1.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransformMakeTranslation(container.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container.frame.width, 0)
        
        let offScreenAbove = CGAffineTransformMakeTranslation(0, -container.frame.height)
        let offScreenBelow = CGAffineTransformMakeTranslation(0, container.frame.height)
        
        if (self.transitionTo == .MODAL) {
            
            
            // start the toView to the right of the screen
            toView.transform = offScreenBelow
            
            // add the both views to our view controller
            container.addSubview(toView)
            container.addSubview(fromView)
            
            // get the duration of the animation
            // DON'T just type '0.5s' -- the reason why won't make sense until the next post
            // but for now it's important to just follow this approach
            let duration = self.transitionDuration(transitionContext)
            
            // perform the animation!
            // for this example, just slid both fromView and toView to the left at the same time
            // meaning fromView is pushed off the screen and toView slides into view
            // we also use the block animation usingSpringWithDamping for a little bounce
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: nil, animations: {
                
                fromView.transform = offScreenAbove
                toView.transform = CGAffineTransformIdentity
                
                }, completion: { finished in
                    
                    // tell our transitionContext object that we've finished animating
                    transitionContext.completeTransition(true)
            })
        } else {
            // start the toView to the right of the screen
            toView.transform = offScreenAbove
            
            // add the both views to our view controller
            container.addSubview(toView)
            container.addSubview(fromView)
            
            // get the duration of the animation
            // DON'T just type '0.5s' -- the reason why won't make sense until the next post
            // but for now it's important to just follow this approach
            let duration = self.transitionDuration(transitionContext)
            
            // perform the animation!
            // for this example, just slid both fromView and toView to the left at the same time
            // meaning fromView is pushed off the screen and toView slides into view
            // we also use the block animation usingSpringWithDamping for a little bounce
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: nil, animations: {
                
                fromView.transform = offScreenBelow
                toView.transform = CGAffineTransformIdentity
                
                }, completion: { finished in
                    
                    // tell our transitionContext object that we've finished animating
                    transitionContext.completeTransition(true)
            })

        }
        
//        STEP 2A: From the First View(INITIAL) -> to the Second View(MODAL)
//        if (self.transitionTo == .MODAL) {
//            //1.Settings for the fromVC
//            var rotation = CGAffineTransformMakeRotation(3.14)
//            fromVC?.view.frame = sourceRect
//            fromVC?.view.layer.anchorPoint = CGPointMake(0.5, 0.0)
//            fromVC?.view.layer.position = CGPointMake(185.5, 0.0)
//            
//            //2.Insert the toVC view
//            var container = transitionContext.containerView()
//            container.insertSubview(toVC!.view, belowSubview: fromVC!.view)
//            let final_toVC_Center = toVC?.view.center
//            
//            toVC?.view.center = CGPointMake(-sourceRect.size.width, sourceRect.size.height)
//            toVC?.view.transform = CGAffineTransformMakeRotation(1.57)
//            
//            //3.Perform the animation
//            UIView.animateWithDuration(2.0,
//                delay: 0.0,
//                usingSpringWithDamping: 0.8,
//                initialSpringVelocity: 6.0,
//                options: UIViewAnimationOptions.CurveEaseIn,
//                animations: { () -> Void in
//                    fromVC!.view.transform = rotation;
//                    toVC!.view.center = final_toVC_Center!;
//                    toVC!.view.transform = CGAffineTransformMakeRotation(0);
//                },
//                completion: { (Bool) -> Void in
//                    
//            })
//        }
//        //STEP 2B: From the Second view(MODAL) -> to the First View(INITIAL)
//        else{
//
//            //1.Settings for the fromVC
//            var rotation = CGAffineTransformMakeRotation(3.14)
//            fromVC?.view.frame = sourceRect
//            fromVC?.view.layer.anchorPoint = CGPointMake(0.5, 0.0)
//            fromVC?.view.layer.position = CGPointMake(185.5, 0)
//            toVC?.view.transform = CGAffineTransformMakeRotation(-3.14)
//
//            
//            //2.Insert the toVC view
//            var container = transitionContext.containerView()
//            container.insertSubview(toVC!.view, belowSubview: fromVC!.view)
//            let final_toVC_Center = toVC?.view.center
//
//            
//            //3.Perform the animation
//            UIView.animateWithDuration(2.0,
//                delay: 0.0,
//                usingSpringWithDamping: 0.8,
//                initialSpringVelocity: 6.0,
//                options: UIViewAnimationOptions.CurveEaseIn,
//                animations: { () -> Void in
//                    fromVC!.view.center = CGPointMake(fromVC!.view.center.x - 375, fromVC!.view.center.y)
//                    toVC!.view.transform = CGAffineTransformMakeRotation(-0)
//                },
//                completion: { (Bool) -> Void in
//                    
//            })
//        }
    }
}
