//
//  ReviewsViewController.swift
//  Givnite
//
//  Created by Danny Tan on 8/1/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
class ReviewsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
 
    
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com/")
    
    var reviewers: [Reviewer]?
    let user = FIRAuth.auth()!.currentUser
    var reviewArray = [String] ()
    
    var userIDArray = [String]()
    var userID: String?
    var timeArray = [Int]()
    var sameUser: Bool = true
    var fromTabBar: Bool = true
    
    
    
    func getReviews() {
        
        reviewArray.removeAll()
        timeArray.removeAll()
        reviewers?.removeAll()
        userIDArray.removeAll()

        
        self.reviewers = [Reviewer] ()
        
        if fromTabBar == true {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        
        if userID == nil {
            userID = user!.uid
        }
        databaseRef.child("user").child(userID!).child("reviews").queryOrderedByChild("time").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            if let keys = snapshot.value?.allKeys as? [String] {
            
                for key in keys {
                    
                    if let reviews = snapshot.value![key] as? NSDictionary {
                        if let time = reviews["time"] as? Int {
                            self.timeArray.append(time)
                        }
                    }
                }
                
                self.timeArray = self.timeArray.sort().reverse()
                for time in self.timeArray {
                    for key in keys {
                        if let keyDictionary = snapshot.value![key] as? NSDictionary {
                            if let time2 = keyDictionary["time"]{
                                if time == time2 as! Int {
                                    self.reviewArray.append(key)
                                }
                            }
                        }
                    }
                }

                self.getReviewInfo()
            
            }

        })
    }
    
    
    func getReviewInfo() {
        

        databaseRef.child("user").child(userID!).child("reviews").queryOrderedByChild("time").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            for reviewString in self.reviewArray {
                var aReviewer = Reviewer()
                if let reviews = snapshot.value![reviewString] as? NSDictionary {
                    if let review = reviews["review"] as? String {
                        aReviewer.review = review
                    }
                    if let user = reviews["user"] as? String {
                        
                        self.userIDArray.append(user)
                        self.databaseRef.child("user").child(user).observeSingleEventOfType(.Value, withBlock: { (snapshot)
                            in
                            
                            if let name = snapshot.value!["name"] as? String {
                                aReviewer.name = name
                            }
                            if let school = snapshot.value!["school"] as? String {
                                aReviewer.school = school
                            }
                            
                            if let picture = snapshot.value!["picture"] as? String {
                                aReviewer.picture = picture
                            }
                        
                            var newReviewString = reviewString
                            
                            for index in 1...9 {
                                newReviewString = String(newReviewString.characters.dropLast())
                            }
                        
                            
                            
                            aReviewer.reviewDate = newReviewString
                            
                            self.reviewers?.append(aReviewer)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                            
                            
                        })
                    }
                }
            }
        })
    
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if sameUser == true {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        
        
        getReviews()

   

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackToProfileView(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func leaveReview(sender: AnyObject) {
        
        performSegueWithIdentifier("leaveReview", sender: self)
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("goToProfileFromReview", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "leaveReview" {
            
            let navigationVC = segue.destinationViewController as! UINavigationController
            let destinationVC = navigationVC.viewControllers[0] as! LeaveReviewViewController
            destinationVC.userID = self.userID
        }
        
        else if segue.identifier == "goToProfileFromReview" {
            
            let indexPath = self.tableView!.indexPathForSelectedRow
            
            
            let destinationVC = segue.destinationViewController as! UINavigationController
            let destVC = destinationVC.viewControllers[0] as! ProfileViewController
            destVC.userID = userIDArray[indexPath!.row]
            destVC.otherUser = true
            destVC.chatButtonHidden = true

            
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewers!.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        cell.reviewer = reviewers![indexPath.row]
        return cell
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.getReviews()
    }
    
}
