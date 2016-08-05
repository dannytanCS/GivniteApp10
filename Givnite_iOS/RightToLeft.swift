//
//  RightToLeft.swift
//  Givnite
//
//  Created by Parth Bhardwaj on 7/17/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit

class RightToLeft: UIStoryboardSegue {
    
    override func perform() {
        //Fetch the source and destination view controllers
        let firstVCView = self.sourceViewController.view as UIView
        let secondVCView = self.destinationViewController.view as UIView
        
        //Get screen width and height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        //Initial position of the destination view
        secondVCView.frame = CGRectMake(screenWidth, 0.0, screenWidth, screenHeight)
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        //Animate the transition
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, -screenWidth, 0.0)
            secondVCView.frame = CGRectOffset(secondVCView.frame, -screenWidth, 0.0)
            }) { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
        }
    }
    
}