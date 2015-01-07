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
//        //STEP 1
//        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//        CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
        var fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var sourceRect = transitionContext.initialFrameForViewController(fromVC!)
        
//        
//        /*STEP 2:   Draw different transitions depending on the view to show
//        for sake of clarity this code is divided in two different blocks
//        */
//
        //STEP 2A: From the First View(INITIAL) -> to the Second View(MODAL)
        if (self.transitionTo == .MODAL) {
            //1.Settings for the fromVC
            var rotation = CGAffineTransformMakeRotation(3.14)
            fromVC?.view.frame = sourceRect
            fromVC?.view.layer.anchorPoint = CGPointMake(0.5, 0.0)
            fromVC?.view.layer.position = CGPointMake(160.0, 0)
            
            //2.Insert the toVC view
            var container = transitionContext.containerView()
            container.insertSubview(toVC!.view, belowSubview: fromVC!.view)
            let final_toVC_Center = toVC?.view.center
            
            toVC?.view.center = CGPointMake(-sourceRect.size.width, sourceRect.size.height)
            toVC?.view.transform = CGAffineTransformMakeRotation(1.57)
            
            //3.Perform the animation
            UIView.animateWithDuration(2.0,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 6.0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: { () -> Void in
                    fromVC!.view.transform = rotation;
                    toVC!.view.center = final_toVC_Center!;
                    toVC!.view.transform = CGAffineTransformMakeRotation(0);
                },
                completion: { (Bool) -> Void in
                    
            })
        }
        //STEP 2B: From the Second view(MODAL) -> to the First View(INITIAL)
        else{

            //1.Settings for the fromVC
            var rotation = CGAffineTransformMakeRotation(3.14)
            fromVC?.view.frame = sourceRect
            fromVC?.view.layer.anchorPoint = CGPointMake(0.5, 0.0)
            fromVC?.view.layer.position = CGPointMake(160.0, 0)
            toVC?.view.transform = CGAffineTransformMakeRotation(-3.14)

            
            //2.Insert the toVC view
            var container = transitionContext.containerView()
            container.insertSubview(toVC!.view, belowSubview: fromVC!.view)
            let final_toVC_Center = toVC?.view.center

            
            //3.Perform the animation
            UIView.animateWithDuration(2.0,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 6.0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: { () -> Void in
                    fromVC!.view.center = CGPointMake(fromVC!.view.center.x - 320, fromVC!.view.center.y)
                    toVC!.view.transform = CGAffineTransformMakeRotation(-0)
                },
                completion: { (Bool) -> Void in
                    
            })
        }
    }
}
