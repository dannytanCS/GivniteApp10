//
//  LeaveReviewViewController.swift
//  Givnite_iOS
//
//  Created by Danny Tan on 8/5/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LeaveReviewViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var reviewerLeaveMessageTextView: UITextView!
    
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com/")
    var placeHolderText: String = "Leave a review"
    let user = FIRAuth.auth()!.currentUser
    
    
    var userID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        if reviewerLeaveMessageTextView.text.isEmpty {
            reviewerLeaveMessageTextView.text = placeHolderText
            reviewerLeaveMessageTextView.textColor = UIColor.lightGrayColor()
        }
        
        
        
        self.reviewerLeaveMessageTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func submitReview(sender: AnyObject) {
        
        reviewerLeaveMessageTextView.resignFirstResponder()
        
   
        
        let dateformatter = NSDateFormatter()
        dateformatter.timeZone = NSTimeZone(abbreviation: "EST")
        dateformatter.dateFormat = "MMMM dd, yyyy HH:mm:ss"
        
        let dateString = dateformatter.stringFromDate(NSDate())
        let time = FIRServerValue.timestamp()
        
        
        if reviewerLeaveMessageTextView.text == placeHolderText {
            reviewerLeaveMessageTextView.text = ""
            
        }
        databaseRef.child("user").child(userID!).child("reviews").child(dateString).child("review").setValue(reviewerLeaveMessageTextView.text)
        databaseRef.child("user").child(userID!).child("reviews").child(dateString).child("user").setValue(user!.uid)
        databaseRef.child("user").child(userID!).child("reviews").child(dateString).child("time").setValue(time)
        
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    //hides keyboard when enter is pressed
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //hides keyboard when tap
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    
    
    
    // Placeholder Color
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGrayColor()
        }
    }


    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButton(sender: AnyObject) {
        
       reviewerLeaveMessageTextView.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
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
