//
//  SchoolViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/7/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SchoolViewController: UIViewController, UITextFieldDelegate {
    
    let dataRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com/")
    
    //MARK: School Name
    
    var schoolName = ""
    var NYUClicked : Bool = false
    var CooperClicked : Bool = false
    var TheNewSchoolClicked : Bool = false
    var BaruchClicked : Bool = false
    var FITClicked : Bool = false
    var SVAClicked : Bool = false

    
    
    
    @IBOutlet weak var schoolButton: UIButton!
    @IBOutlet weak var betaButton: UIButton!
    
    @IBAction func betaButtonPushed(sender: AnyObject) {
        let user = FIRAuth.auth()?.currentUser
        dataRef.child("user").child(user!.uid).child("school").setValue("Beta School")
    }
    // NYU
    @IBOutlet weak var NYUButton: UIButton!
    
    @IBAction func NYUClicked(sender: AnyObject) {
        if ((CooperClicked || TheNewSchoolClicked || BaruchClicked || FITClicked || SVAClicked) == false) {
            if NYUClicked {
                self.NYUButton.setImage(UIImage(named: "NYU Black Logo"), forState: .Normal)
                NYUClicked = false
                self.schoolButton.hidden = true
                betaButton.hidden = false
            }
            else{
                self.schoolButton.setTitle("New York University", forState: .Normal)
                self.NYUButton.setImage(UIImage(named: "NYU Color Logo"), forState: .Normal)
                NYUClicked = true
                schoolName = "New York University"
                let user = FIRAuth.auth()?.currentUser
                dataRef.child("user").child(user!.uid).child("school").setValue(schoolName)
                self.schoolButton.hidden = false
                betaButton.hidden = true
    
            }
        }
    }
    
    //Cooper Union
    @IBOutlet weak var CooperButton: UIButton!
    
    @IBAction func CooperClicked(sender: AnyObject) {
        if (NYUClicked || TheNewSchoolClicked || BaruchClicked || FITClicked || SVAClicked) == false  {
            if CooperClicked {
                self.CooperButton.setImage(UIImage(named: "CU Black Logo"), forState: .Normal)
                CooperClicked = false
                 self.schoolButton.hidden = true
                  betaButton.hidden = false
            }
            else{
                self.schoolButton.setTitle("Cooper Union", forState: .Normal)
                self.CooperButton.setImage(UIImage(named: "CU Color Logo"), forState: .Normal)
                CooperClicked = true
                schoolName = "Cooper Union"
                let user = FIRAuth.auth()?.currentUser
                dataRef.child("user").child("\(user!.uid)/school").setValue(schoolName)
                self.schoolButton.hidden = false
                betaButton.hidden = true
            }
        }

    }
    
    //The New School
    
    @IBOutlet weak var TheNewSchoolButton: UIButton!
    
    @IBAction func TheNewSchoolClicked(sender: AnyObject) {
        if (NYUClicked || CooperClicked || BaruchClicked || FITClicked || SVAClicked) == false {
            if TheNewSchoolClicked {
                self.TheNewSchoolButton.setImage(UIImage(named: "The New School Black Logo"), forState: .Normal)
                TheNewSchoolClicked = false
                 self.schoolButton.hidden = true
                  betaButton.hidden = false
            }
            else{
                self.schoolButton.setTitle("The New School", forState: .Normal)
                self.TheNewSchoolButton.setImage(UIImage(named: "The New School Color Logo"), forState: .Normal)
                TheNewSchoolClicked = true
                schoolName = "The New School"
                let user = FIRAuth.auth()?.currentUser
                dataRef.child("user").child("\(user!.uid)/school").setValue(schoolName)
                self.schoolButton.hidden = false
                betaButton.hidden = true
            
              
            }
        }

    }
    
    //Baruch
    
    @IBOutlet weak var BaruchButton: UIButton!
    
    @IBAction func BaruchClicked(sender: AnyObject) {
        if (NYUClicked || TheNewSchoolClicked || CooperClicked || FITClicked || SVAClicked) == false {
            if BaruchClicked {
                self.BaruchButton.setImage(UIImage(named: "Baruch Black Logo"), forState: .Normal)
                BaruchClicked = false
                self.schoolButton.hidden = true
                  betaButton.hidden = false
            }
            else{
                self.schoolButton.setTitle("Baruch College", forState: .Normal)
                self.BaruchButton.setImage(UIImage(named: "Baruch Color Logo"), forState: .Normal)
                BaruchClicked = true
                schoolName = "Baruch College"
                let user = FIRAuth.auth()?.currentUser
                dataRef.child("user").child("\(user!.uid)/school").setValue(schoolName)
                self.schoolButton.hidden = false
                betaButton.hidden = true
            }
        }

    }
    
    
    //FIT
    
    @IBOutlet weak var FITButton: UIButton!
    
    @IBAction func FITClicked(sender: AnyObject) {
        if (NYUClicked || TheNewSchoolClicked || BaruchClicked || CooperClicked || SVAClicked) == false  {
            if FITClicked {
                self.FITButton.setImage(UIImage(named: "FIT Black Logo"), forState: .Normal)
                FITClicked = false
                self.schoolButton.hidden = true
                  betaButton.hidden = false
            }
            else{
                self.schoolButton.setTitle("Fashion Institute of Technology", forState: .Normal)
                self.FITButton.setImage(UIImage(named: "FIT Color Logo"), forState: .Normal)
                FITClicked = true
                schoolName = "Fashion Institute of Technology"
                let user = FIRAuth.auth()?.currentUser
                dataRef.child("user").child("\(user!.uid)/school").setValue(schoolName)
                self.schoolButton.hidden = false
                betaButton.hidden = true
               
            }
        }

    }
    
    
    //SVA
    
    @IBOutlet weak var SVAButton: UIButton!
    
    @IBAction func SVAClicked(sender: AnyObject) {
        if (NYUClicked || TheNewSchoolClicked || BaruchClicked || FITClicked || CooperClicked) == false  {
            if SVAClicked {
                self.SVAButton.setImage(UIImage(named: "SVA Black Logo"), forState: .Normal)
                SVAClicked = false
                self.schoolButton.hidden = true
                  betaButton.hidden = false
            }
            else{
                self.schoolButton.setTitle("School of Visual Arts", forState: .Normal)
                self.SVAButton.setImage(UIImage(named: "SVA Color Logo"), forState: .Normal)
                SVAClicked = true
                schoolName = "School of Visual Arts"
                let user = FIRAuth.auth()?.currentUser
                dataRef.child("user").child("\(user!.uid)/school").setValue(schoolName)
                self.schoolButton.hidden = false
                betaButton.hidden = true
            }
        }

    }
    
    
    @IBAction func joinNow(sender: AnyObject) {
        let user = FIRAuth.auth()?.currentUser
        
        dataRef.child("user").child(user!.uid).child("query").setValue("")
        dataRef.child("user").child(user!.uid).child("queryres").child("0").setValue("")
        dataRef.child("user").child(user!.uid).child("queryres").child("1").setValue("")
        dataRef.child("user").child("\(user!.uid)/graduation year").setValue(GraduationYear.text)
        dataRef.child("user").child("\(user!.uid)/major").setValue(Major.text)
        dataRef.child("user").child(user!.uid).child("reviews").setValue("False")
    
        
//        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TabBarControllerView")
//        
//        self.presentViewController(homeViewController, animated: true, completion: nil)
        performSegueWithIdentifier("GoToProfile", sender: self)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToProfile" {
            let destinationVC = segue.destinationViewController as! UITabBarController
            destinationVC.selectedIndex = 2
        }
    }
    
    
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.GraduationYear {
            guard let text = textField.text else { return true }
        
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 4
        }
        else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: School Info
    
    @IBOutlet weak var GraduationYear: UITextField!
    @IBOutlet weak var Major: UITextField!
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SchoolViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        if (Major != nil){
            self.Major.delegate = self
            self.GraduationYear.delegate = self
        }

    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
