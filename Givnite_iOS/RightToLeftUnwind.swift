//
//  RightToLeftUnwind.swift
//  Givnite
//
//  Created by Parth Bhardwaj on 7/17/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit

class RightToLeftUnwind: UIStoryboardSegue {
    
    override func perform() {
        //Variables for the two view controllers
        let secondVCView = self.sourceViewController.view as UIView
        let firstVCView = self.destinationViewController.view as UIView
        
        //Get screen width and height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        //we don't need to set initial frame of the firstVC because we never really dismissed it
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(firstVCView, aboveSubview: secondVCView)
        
        //Animate the transition
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, screenWidth, 0.0)
            secondVCView.frame = CGRectOffset(secondVCView.frame, screenWidth, 0.0)
            }) { (Finished) -> Void in
                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
        
        
    }
    
}