//
//  ProfileViewController.swift
//  Givnite
//
//  Created by Danny Tan  on 7/3/16.
//  Copyright © 2016 Givnite. All rights reserved.
//



import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

protocol dropAndChat : class{
    func chatAfterDismiss(chatUID:String)
}


class ProfileViewController: UIViewController, UITextViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource, letsJiggyDelegate{
    
    // Connect to Firebase
    let storageRef = FIRStorage.storage().referenceForURL("gs://givnite-ios.appspot.com")
    let dataRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com/")
    let user = FIRAuth.auth()!.currentUser
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var graduationYearLabel: UILabel!
    @IBOutlet weak var addButton: SpringButton!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var profileUIView: UIView!
    
    //connection buttons
    @IBOutlet weak var connectButton: DesignableButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var startChat: UIImageView!
   
    var name: String = ""
    
    
    //posts, givnitees, reviews
    
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var givniteesButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    
    //delegate to go to chat from other user's profile
    weak var dismissDelegate : dropAndChat?
    var currentStateConnection:String?
    var imageNameArray = [String]()
    var imageArray = [UIImage]()
    var userID: String?
    var otherUser: Bool = false
    var placeHolderText: String = "Tell us about yourself!"
    let screenSize = UIScreen.mainScreen().bounds
    let givniteColor = UIColor(colorLiteralRed: 255/255, green: 80/255, blue: 85/255, alpha: 1)
    
    //from market item VC
    var marketVC: Bool = false
    var savedImageName: String?
    
    //Chat Addition
    var fbUID: String?
    var currentUserName: String?
    let firebaseUID = FIRAuth.auth()?.currentUser?.uid

    var chatButtonHidden: Bool = false
    
    // SpringButton Animation
    func timefunc()
    {
        addButton.animation = "pop"
        addButton.curve = "easeIn"
        addButton.duration = 1.0
        addButton.x = 0
        addButton.force = 0.5
        addButton.velocity = 0.1
        addButton.damping = 1
        addButton.animate()
    }
    
    func timefuncNew()
    {
        addButton.animation = "shake"
        addButton.curve = "linear"
        addButton.duration = 1.0
        addButton.animate()
    }
    
    // View Loaded
    override func viewDidLoad() {
        
        
        connectButton.hidden = true
        
        
    
        
        if otherUser == false {
            
            self.navigationItem.leftBarButtonItem = nil;
            
            if marketVC == false {
                userID = self.user?.uid
                storesInfoFromFB()
            }
            
        }
        if otherUser == true || marketVC == true {
            self.navigationItem.rightBarButtonItem = nil;
            addButton.hidden = true
            if (user!.uid != userID!) {
                
                connectButton.hidden = false
            }
        }
        
        if marketVC == true {
            otherUser = marketVC
        }

       
        //Put Shadow under the profile section
        self.profileUIView.layer.shadowOffset = CGSizeMake(0, 1)
        self.profileUIView.layer.shadowRadius = 1
        self.profileUIView.layer.shadowOpacity = 0.5
        
        if self.userID == nil{
            otherUser = false;
            startChat.hidden = true
        }else if self.userID != nil && self.userID != FIRAuth.auth()?.currentUser?.uid{
            otherUser = true;
            startChat.hidden = false
            startChat.userInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.newChatFromProfile))
            tapRecognizer.numberOfTapsRequired = 1
            startChat.addGestureRecognizer(tapRecognizer)
        }else if self.userID != nil && self.userID == FIRAuth.auth()?.currentUser?.uid{
            otherUser = false;
            startChat.hidden = true
        }
        
        
        if chatButtonHidden == true {
            self.startChat.hidden = true
        }

        
    // Animate the camera upload button
    NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(ProfileViewController.timefuncNew), userInfo: nil, repeats: true)
        

    self.view.bringSubviewToFront(addButton)
    //self.view.bringSubviewToFront(settingButton)
        
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
    self.profilePicture.clipsToBounds = true
    self.profilePicture.layer.borderWidth = 2
    self.profilePicture.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).CGColor
    
        
    getPostsNumber()
    getGivniteesNumber()
    getReviewNumber()
        
    loadImages()
    getProfileImage()
    schoolInfo()
       
        self.bioTextView.editable = false
    }
    
    
    
    //gets the number of posts
    func getPostsNumber() {
        

        dataRef.child("user").child(userID!).child("items").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in

            let postNumber = snapshot.childrenCount
            
            self.postsButton.setTitle("\(postNumber)", forState: .Normal)
        })
    }
    
    //gets the number of posts
    func getGivniteesNumber() {
        
    
        dataRef.child("user").child(userID!).child("connections").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            var givniteesNumber = 0
            
            if let connectionDictionary = snapshot.value as? NSDictionary {
                let connectionValues = connectionDictionary.allValues as? [Int]
                
                for values in connectionValues! {
                    if values == 2 {
                        givniteesNumber += 1
                    }
                }
                
            }
            
            self.givniteesButton.setTitle("\(givniteesNumber)", forState: .Normal)
        })
    }
    
    //gets the number of posts
    func getReviewNumber() {
        
        dataRef.child("user").child(userID!).child("reviews").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
    
            var reviewsNumber = snapshot.childrenCount
            
            self.reviewsButton.setTitle("\(reviewsNumber)", forState: .Normal)
        })
    }
    
    
    
    
    //LOWER TWO FUNCTIONS ARE CHAT ADDITIONS
    //CHAT ADDITIONS
    //functions for gesture recognizers
    
    func showChatsTableView(){
        self.performSegueWithIdentifier("toChatsTableView", sender: self)
    }
    func showMarketplace(){
        self.performSegueWithIdentifier("toMarketplace", sender: self)
    }
    func backToUserItem() {
        self.performSegueWithIdentifier("backToItem", sender: self)
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    //layout for cell size
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 3)/3, height: (collectionView.frame.size.width - 3)/3 )
    }

    
    
    //back to marketplace
    @IBAction func backToMarketplace(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //loads images from cache or firebase
    func loadImages() {
        dataRef.child("user").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            //adds image name from firebase database to an array
            if let itemDictionary = snapshot.value!["items"] as? NSDictionary {
                let sortKeys = itemDictionary.keysSortedByValueUsingComparator {
                    (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
                    let x = obj1 as! NSNumber
                    let y = obj2 as! NSNumber
                    return y.compare(x)
                }
            
                for key in sortKeys {
                    self.imageNameArray.append("\(key)")
                }
                if (self.imageArray.count == 0){
                    for index in 0..<self.imageNameArray.count {
                        self.imageArray.append(UIImage(named: "Examples")!)
                    }
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.collectionView.reloadData()
                })
            }
        })
    
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
    
    //Sets up the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNameArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!
        CollectionViewCell
        
        
        if let imageName = self.imageNameArray[indexPath.row] as? String {
            var num = indexPath.row
            cell.imageView.image = nil
            
            
            if let image = NSCache.sharedInstance.objectForKey(imageName) as? UIImage{
                cell.imageView.image = image
                self.imageArray[indexPath.row] = image
            }
                
            else {
                
                var profilePicRef = storageRef.child(imageName).child("\(imageName).jpg")
                //sets the image on profile
                profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print ("File does not exist")
                        return
                    } else {
                        if (data != nil){
                            let imageToCache = UIImage(data:data!)
                            NSCache.sharedInstance.setObject(imageToCache!, forKey: imageName)
                            //update to the correct cell
                            if (indexPath.row == num){
                                dispatch_async(dispatch_get_main_queue(),{
                                    cell.imageView.image = imageToCache
                                    self.imageArray[indexPath.row] = imageToCache!
                                    
                                })
                            }
                        }
                    }
                }.resume()
            }
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showImage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            let destinationVC = segue.destinationViewController as! ItemViewController
            
            
            destinationVC.image = self.imageArray[indexPath.row]
            destinationVC.imageName  = self.imageNameArray[indexPath.row]
            destinationVC.userName = self.name
            destinationVC.otherUser = self.otherUser.boolValue
            destinationVC.userID = self.userID
            destinationVC.fromProfile = true
            
        }
        
        
        if segue.identifier == "showReview" {
            
            
            let navigationVC = segue.destinationViewController as! UINavigationController
            
            let destinationVC = navigationVC.viewControllers[0] as! ReviewsViewController
            
            destinationVC.fromTabBar = false
            destinationVC.userID = self.userID
            
            if otherUser == true {
                destinationVC.sameUser = false
                
            }
            
            
        }
    }
    
    
    
    var profileImageCache = NSCache()
    

    //gets and stores info from facebook
    func storesInfoFromFB(){
        
        dataRef.child("user").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            // Get user value
            if let name = snapshot.value!["name"] as? String {
                return
            }
            else {
        
                let profilePicRef = self.storageRef.child(self.userID!+"/profile_pic.jpg")
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, id, gender, email, picture.type(large)"]).startWithCompletionHandler{(connection, result, error) -> Void in
                    
                    if error != nil {
                        print (error)
                        return
                    }
                    
                    if let name = result ["name"] as? String {
                        self.dataRef.child("user").child(self.userID!).child("name").setValue(name)
                    
                        self.navigationItem.title = name
                        //CHAT ADDITION
                        self.currentUserName = name
                        

                        
                    }
                    
                    if let profileID = result ["id"] as? String {
                        self.dataRef.child("user").child(self.userID!).child("ID").setValue(profileID)
                       
                        
                        //CHAT ADDITION
                        self.fbUID = profileID
                    }
                    
                    if let gender = result ["gender"] as? String {
                        self.dataRef.child("user").child(self.userID!).child("gender").setValue(gender)
                    }
                    
                    if let email = result["email"] as? String {
                        self.dataRef.child("user").child(self.userID!).child("email").setValue(email)
                    }
                    
                    
                    self.dataRef.child("user").child(self.userID!).child("picture").observeSingleEventOfType(.Value, withBlock: { (snapshot)
                        in
                        
                     
                        if let url = snapshot.value as? String {
                         
                            return
                        }
                        else {
                            if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary,url = data["url"] as? String {
                            
                                if let imageData = NSData(contentsOfURL: NSURL (string:url)!) {
                                    
                                    self.profilePicture.image = UIImage(data:imageData)
                                    let uploadTask = profilePicRef.putData(imageData, metadata: nil){
                                        metadata, error in
                                            
                                        if(error == nil) {
                                            let downloadURL = metadata!.downloadURL
                                            
                                            profilePicRef.downloadURLWithCompletion { (URL, error) -> Void in
                                                if (error != nil) {
                                                    // Handle any errors
                                                    print(error)
                                                }
                                                else {
                                                    self.dataRef.child("user").child("\(self.user!.uid)/picture").setValue("\(URL!)")
                                                }
                                            }
                                        }
                                        else{
                                            print ("Error in downloading image")
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    

    
    var schoolName = ""
    var newName: String = ""
  

    
    
    func schoolInfo() {
        dataRef.child("user").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            // Get user value
            if let name = snapshot.value!["name"] as? String {
                self.name = name
                self.newName = name
                print(self.newName + "hahahah")
                self.navigationItem.title = self.newName
                
                
                
            }
            if let school = snapshot.value!["school"] as? String {
                self.schoolName = school
            }
            if let graduationYear = snapshot.value!["graduation year"] as? String {
                
                let index = graduationYear.startIndex.advancedBy(2)
                let endIndex = graduationYear.endIndex.advancedBy(-1)
                let lastTwoDigitofGraduationYear = graduationYear[Range(index...endIndex)]
                self.graduationYearLabel.text = self.schoolName + " " + "'"+lastTwoDigitofGraduationYear

            
            }
            if let major = snapshot.value!["major"] as? String {
                self.majorLabel.text = major
            }
            

            if let bioDescription = snapshot.value!["bio"] as? String {

                if bioDescription == "" || bioDescription == self.placeHolderText{
                    self.bioTextView.text = ""
                    self.bioTextView.textColor = UIColor.lightGrayColor()
                }
                else {
                    
                    self.bioTextView.text = bioDescription
                }
            }
            })
        
        
        if (userID != user!.uid) {
        
            dataRef.child("user").child(userID!).child("connections").child(self.user!.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot)
                in
                if let value = snapshot.value! as? Int {
                    if value == 0 {
                      
                        self.connectButton.setTitle("CONFIRM", forState: .Normal)
                        self.currentStateConnection = "0"
                        self.connectButton.layer.borderWidth = 1.0
                        self.connectButton.layer.borderColor = UIColor.whiteColor().CGColor
                        self.connectButton.backgroundColor = UIColor.whiteColor()
                        self.connectButton.setTitleColor(self.givniteColor, forState: .Normal)
                        self.connectButton.layer.cornerRadius = 2
                        self.connectButton.layer.cornerRadius = 2
                        
                    }
                    if value == 1 {
                        self.connectButton.setTitle("REQUESTED", forState: .Normal)
                        self.currentStateConnection = "1"
                        
                        self.connectButton.layer.borderWidth = 1.0
                        self.connectButton.layer.cornerRadius = 2
                        
                        self.connectButton.layer.borderColor = UIColor.whiteColor().CGColor
                        self.connectButton.backgroundColor = UIColor.whiteColor()
                        self.connectButton.setTitleColor(self.givniteColor, forState: .Normal)
                        self.connectButton.layer.shadowOffset = CGSizeMake(0, 0)
                      
                    }
                    
                    if value == 2 {
                        self.connectButton.setTitle("GIVNITED", forState: .Normal)
                        self.currentStateConnection = "2"
                   
                        self.connectButton.layer.borderWidth = 1.0
                        self.connectButton.layer.borderColor = UIColor.whiteColor().CGColor
                        self.connectButton.backgroundColor = self.givniteColor as UIColor
                        self.connectButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                            self.connectButton.layer.cornerRadius = 2
                    }
                }
                else {
                    self.connectButton.setTitle("ADD", forState: .Normal)
                    self.currentStateConnection = "3"
                    
                        self.connectButton.backgroundColor = UIColor.whiteColor()
                    self.connectButton.setTitleColor(self.givniteColor, forState: .Normal)
                    self.connectButton.layer.cornerRadius = 2
                    
                    self.connectButton.layer.shadowOffset = CGSizeMake(0, 2)
                    self.connectButton.layer.shadowRadius = 1
                    self.connectButton.layer.shadowOpacity = 0.5
                    self.connectButton.layer.cornerRadius = 2

                    
                    
                }
                
            })
        }

    }
    
    func getProfileImage() {
        
        if let image = NSCache.sharedInstance.objectForKey(userID!) as? UIImage{
            self.profilePicture.image = image
        }
        else {
            getImageFromStorage()
        }
    }

    
    func getImageFromStorage() {
        let profilePicRef = storageRef.child(userID!+"/profile_pic.jpg")
        profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                var cacheImage = UIImage(data: data!)
            
                self.profilePicture.image = cacheImage
                NSCache.sharedInstance.setObject(cacheImage!, forKey: self.userID!)
            }
        }

    }
    
    func onDismiss(sender:UIViewController){
        
    }

    
    func newChatFromProfile(){
        print("new message from prof")
        let startChats = startNewChat()
        startChats.delegate = self
        startChats.userID = self.userID
        startChats.userName = self.currentUserName
        startChats.startNewChat()
    }
    
    func jiggyIntoChat(chatUID:String?){
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.dismissDelegate?.chatAfterDismiss(chatUID!)
            self.onDismiss(self)
        }
//        let barViewControllers = self.tabBarController?.viewControllers
//        let destVC = barViewControllers![1] as! UINavigationController
//        
//        let chatVC = destVC.viewControllers.first as! ChatsTableViewController
//        chatVC.fbUID = ""
//        chatVC.firebaseUID = FIRAuth.auth()?.currentUser?.uid
//        chatVC.userName = FIRAuth.auth()?.currentUser?.displayName
//        chatVC.fromMarketPlace = true
//        chatVC.chatUID = chatUID
//        
//        self.tabBarController?.selectedIndex = 1
    }

    
  @IBAction func cameraPushed(sender: AnyObject) {
        performSegueWithIdentifier("showCamera", sender: self)
    }
    

    ////////////////////////////// CONNECTION /////////////////////////
    //connections functions
    //0 means requested (pending)
    //1 means waiting to connect (on the other user's side)
    //2 means givnited (both accepted)
    
    @IBAction func connectAction(sender: AnyObject) {
        //default
        
        if currentStateConnection! == "3" {
            
            dataRef.child("user").child(user!.uid).child("connections").child(userID!).setValue(0)
            dataRef.child("user").child(userID!).child("connections").child(user!.uid).setValue(1)
            self.connectButton.setTitle("REQUESTED", forState: .Normal)
            self.currentStateConnection = "2"
            
            self.connectButton.layer.borderWidth = 1.0
            self.connectButton.layer.cornerRadius = 2
            
            self.connectButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.connectButton.backgroundColor = UIColor.whiteColor()
            self.connectButton.setTitleColor(self.givniteColor, forState: .Normal)
            self.connectButton.layer.shadowOffset = CGSizeMake(0, 0)
            

            
            
        }
            
            //connected
            
            
        else if currentStateConnection! == "0" {
            
            dataRef.child("user").child(user!.uid).child("connections").child(userID!).setValue(2)
            dataRef.child("user").child(userID!).child("connections").child(user!.uid).setValue(2)
            self.connectButton.setTitle("GIVNITED", forState: .Normal)
            self.currentStateConnection = "2"
            
            
            self.connectButton.layer.borderWidth = 1.0
            self.connectButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.connectButton.backgroundColor = self.givniteColor as UIColor
            self.connectButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.connectButton.layer.cornerRadius = 2
    
        }
            
            //says givnited or requested
            
        else if currentStateConnection! == "2" || currentStateConnection! == "1" {
            
            dataRef.child("user").child(user!.uid).child("connections").child(userID!).removeValue()
            dataRef.child("user").child(userID!).child("connections").child(user!.uid).removeValue()
            self.connectButton.setTitle("ADD", forState: .Normal)
            self.currentStateConnection = "3"
            
            self.connectButton.backgroundColor = UIColor.whiteColor()
            self.connectButton.setTitleColor(givniteColor, forState: .Normal)
            self.connectButton.layer.cornerRadius = 2
            self.connectButton.layer.shadowOffset = CGSizeMake(0, 2)
            self.connectButton.layer.shadowRadius = 1
            self.connectButton.layer.shadowOpacity = 0.5
    
            
        }
    }
    
    
    
    @IBAction func reviewButtonClicked(sender: AnyObject) {
        
        performSegueWithIdentifier("showReview", sender: self)
    }

    
// Show Connections
    
//  @IBAction func showConnections(sender: AnyObject) {
//    
//       let connectionViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("connection")
//        self.presentViewController(connectionViewController, animated: true, completion: nil)
//    }
//    
    
    
    
}
