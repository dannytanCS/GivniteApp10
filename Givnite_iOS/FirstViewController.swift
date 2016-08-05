//
//  ViewController.swift
//  GivniteApp1.0
//
//  Created by Lee SangJoon  on 7/30/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class FirstViewController: UIViewController {
    
    
   @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        self.loadingSpinner.startAnimating()
        super.viewDidLoad()
        //Sign out whenever the user opens up the app
        //try! FIRAuth.auth()!.signOut()
        //FBSDKAccessToken.setCurrentAccessToken(nil)
        
        
        let dataRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com")

        
        // Check whether the user is signed in or not
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                dataRef.child("user").child(user.uid).child("graduation year").observeSingleEventOfType(.Value, withBlock: { (snapshot)
                    in
                    
                    if snapshot.value! is NSString {
                    
                    
                        self.loadingSpinner.stopAnimating()
                        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TabBarControllerView")
                        self.presentViewController(homeViewController, animated: true, completion: nil)
                        
                    }
                        
                    else {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("login")
                        self.presentViewController(loginViewController, animated: false, completion: nil)
                        self.loadingSpinner.stopAnimating()
                    }
                    
                })
            }
                
            else {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("login")
                self.presentViewController(loginViewController, animated: false, completion: nil)
                self.loadingSpinner.stopAnimating()
            }
            
        }
        
    }
    
        
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton) {
        print("User Logged Out")
    }



