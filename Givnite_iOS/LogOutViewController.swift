//
//  LogOutViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/29/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit



class LogOutViewController: UIViewController {

    var LogOutAlert: UIAlertController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        LogOutAlert = UIAlertController(title: "Would you like to log out?", message: "You sure you want to log out?", preferredStyle: .Alert)
        
        let logOutAlertAction = UIAlertAction(title: "Log Out", style: .Default, handler:  { action in
            
            
            let givniteColor = UIColor(colorLiteralRed: 255/255, green: 80/255, blue: 85/255, alpha: 1)
            self.navigationController!.navigationBar.tintColor = givniteColor

            
            
            
            
            
            //sign out
            try! FIRAuth.auth()!.signOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
            
            
            //logs out the user
            print("Log out")
            
            let loginViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("login")
            self.presentViewController(loginViewController, animated: false, completion: nil)
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            
            print("Cancel")
            
            self.navigationController?.popViewControllerAnimated(true)
            
        })
        
        LogOutAlert?.addAction(logOutAlertAction)
        LogOutAlert?.addAction(cancelAction)
        
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.presentViewController(LogOutAlert!, animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
