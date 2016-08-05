 //
//  ItemViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/9/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ItemViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, letsJiggyDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var image = UIImage()

        
    var imageName:String?
    var imageDict = [UIImage:AnyObject]()
    var imageList = [UIImage]()
    var imageNameList = [String]()
    var imageIndex: Int = 0
    var maxImages: Int = 0

    
    //CHAT ADDITION
    //CHAT ADDITION
    var chatUID : String?
    
    
    
      

    
    

    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bookName: UITextField!
    @IBOutlet weak var bookPrice: UITextField!
    @IBOutlet weak var bookDescription: UITextView!
    
    let storageRef = FIRStorage.storage().referenceForURL("gs://givnite-ios.appspot.com")
    let databaseRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com/")

    let user = FIRAuth.auth()!.currentUser
    
    
   
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var btnbtn: SpringButton!
 
    
    
    //book info
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var flipButton: UIButton!

    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var publisher: UILabel!
    @IBOutlet weak var publishedDate: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var bookDescription2: UITextView!
    
    

    var userName: String?
    var otherUser: Bool = false
    var userID: String?
    
    var fromProfile: Bool = false
    

    func timefunc()
    {
        btnbtn.animation = "shake"
        btnbtn.curve = "linear"
        btnbtn.duration = 1.0
        btnbtn.animate()
    }
    
    
    @IBAction func showInfo(sender: AnyObject) {
        
        self.descriptionView.hidden = false
        
    }
    
    
    @IBAction func cancelInfo(sender: AnyObject) {
        
        self.descriptionView.hidden = true
    }
    
    
    
    let givniteColor = UIColor(colorLiteralRed: 255/255, green: 80/255, blue: 85/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = givniteColor
        
        
         var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ItemViewController.timefunc), userInfo: nil, repeats: true)
        
        self.databaseRef.child("user").child(self.userID!).child("name").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            self.userName = snapshot.value as? String
            self.userNameLabel.text = self.userName
             self.navigationItem.title = self.userName

        })

        self.bookDescription.editable = false
        self.bookPrice.userInteractionEnabled = false
        self.bookName.userInteractionEnabled = false
        self.descriptionView.hidden = true

        self.imageView.image = self.image
        self.imageView.layer.cornerRadius = 10
        self.imageView.clipsToBounds = true
        
        self.doneButton.hidden = true
        self.bookName.delegate = self
        self.bookPrice.delegate = self
        self.bookDescription.delegate = self
        self.btnbtn.hidden = true
        
        
        self.flipButton.hidden = true
        self.btnbtn.hidden = true
        

        
        if otherUser {
            
            settingButton.hidden = true
            cameraButton.hidden = true
            deleteButton.hidden = true
            if user!.uid != userID {
                 btnbtn.hidden = false
            }
            
            if fromProfile == true {
                print("yes")
                btnbtn.hidden = true
            }
        }
        
        if user!.uid == userID || fromProfile == true {
            self.navigationItem.rightBarButtonItem = nil
        }
        

        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ItemViewController.swiped(_:))) // put : at the end of method name
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ItemViewController.swiped(_:))) // put : at the end of method name
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ItemViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ItemViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        loadImages()
        
   
    }
    
    
    
    func loadImages() {
        if imageNameList.count == 0 {
            databaseRef.child("marketplace").child(imageName!).child("images").observeSingleEventOfType(.Value, withBlock: { (snapshot)
                in
                
                if let itemDictionary = snapshot.value! as? NSDictionary {
                    
                
                    
                    let sortKeys = itemDictionary.keysSortedByValueUsingComparator {
                        (obj1: AnyObject!, obj2: AnyObject!) -> NSComparisonResult in
                        let x = obj1 as! NSNumber
                        let y = obj2 as! NSNumber
                        return x.compare(y)
                    }
                    
                    for key in sortKeys {
                        self.imageNameList.append("\(key)")
                    }
                    
                    
                    for image in itemDictionary {
                        
                        let imagename = image.key
                       
                        
                        if let imageCache = NSCache.sharedInstance.objectForKey(imagename) as? UIImage {
                            self.imageDict[imageCache] = image.value
                        }
                            
                        else {
                            let profilePicRef = self.storageRef.child(self.imageName!).child("\(imagename).jpg")
                            //sets the image on profile
                            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                                if (error != nil) {
                                    print ("File does not exist")
                                    return
                                } else {
                                    if (data != nil){
                                        var imageToCache = UIImage(data:data!)
                                        NSCache.sharedInstance.setObject(imageToCache!, forKey: imagename)
                                        self.imageDict[imageToCache!] = image.value
                                        
                                    }
                                }
                            }
                        }
                        
                        //change image dictionary into sorted image array
                        var sortedTuples = self.imageDict.sort({ (a, b) in (a.1 as! Double) < (b.1 as! Double) })
                        
                        for tuple in sortedTuples {
                            if sortedTuples.count == self.imageNameList.count {
                                self.imageList.append(tuple.0)
                            }
                        }
                    }
                    
                    
                    self.maxImages  = self.imageList.count - 1
                    self.pageControl.currentPage = 0
                    self.pageControl.numberOfPages = self.maxImages + 1
                    
                }
            })
        }
        bookInfo()
        
    }

    
    
    func bookInfo() {
        databaseRef.child("marketplace").child(imageName!).observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            
            //checks for isbn
            
            if let isbn = snapshot.value!["isbn"] as? String {
                self.flipButton.hidden = false
            }
            
            // Get item information
            if let searchable = snapshot.value!["searchable"] as? NSDictionary {
                if let bookName = searchable["book name"] as? String {
                    self.bookName.text = bookName
                }
                if let bookDescription = searchable["description"] as? String {
                    self.bookDescription.text = bookDescription
                }
                if let title = searchable["title2"] as? String {
                    self.bookTitle.text = title
                }
                if let author = searchable["author"] as? String {
                    self.bookAuthor.text = author
                }
                
                if let publisher = searchable["publisher"] as? String {
                    self.publisher.text = publisher
                }
                
                if let publishedDate = searchable["publishedDate"] as? String {
                    self.publishedDate.text = publishedDate
                }
                if let genre = searchable["categories"] as? String {
                    self.genre.text = genre
                }
                if let description = searchable["description2"] as? String {
                    self.bookDescription2.text = description
                }

                
            }
            
            if let bookPrice = snapshot.value!["price"] as? String {
                self.bookPrice.text = bookPrice
            }
        })
        

    }
    

    
 
                
                
//        else if segue.identifier == "shortToChat"{
//            let destinationNavVC = segue.destinationViewController as! UINavigationController
//            let destVC = destinationNavVC.viewControllers[0] as! ChatsTableViewController
//            destVC.fbUID = ""
//            destVC.userName = FIRAuth.auth()?.currentUser?.displayName
//            destVC.firebaseUID = FIRAuth.auth()?.currentUser?.uid
//            destVC.fromMarketPlace = true
//            destVC.chatUID = self.chatUID
//        }
        
//        if segue.identifier == "cutToChat"{
//            let chatVC = segue.destinationViewController as! SingleChatViewController
//            chatVC.senderId = FIRAuth.auth()?.currentUser?.uid
//            chatVC.senderDisplayName = FIRAuth.auth()?.currentUser?.displayName
//            chatVC.chatUID = self.chatUID
//            chatVC.fromMarketPlace = true
//        }


    
    @IBAction func deleteItem(sender: AnyObject) {
        
        
        let alert = UIAlertController(title: "Delete \"\(bookName.text!)\"", message: "Deleting \"\(bookName.text!)\" will also delete all of its data", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style:.Default, handler: { action in
            for imageName in self.imageNameList{
            
                self.storageRef.child(imageName).deleteWithCompletion { (error) -> Void in
                    if (error != nil) {
                    // Uh-oh, an error occurred!
                    } else {
                        // File deleted successfully
                        print("file deleted")
                    }
                }
            }
            self.databaseRef.child("user").child(self.user!.uid).child("items").child(self.imageName!).removeValue()
            self.databaseRef.child("marketplace").child(self.imageName!).removeValue()

            
            
            let profileViewController: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarControllerView")
            
            self.presentViewController(profileViewController, animated: false, completion: nil)
        }))
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
        print("Click of cancel button")
            
            
        }))
        
        
        
        alert.view.tintColor = UIColor(red: 0.984314, green: 0.211765, blue: 0.266667, alpha: 1)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    

    
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Right :
                print("User swiped right")
                
                // decrease index first
                
                imageIndex -= 1
                self.pageControl.currentPage -= 1
                
                // check if index is in range
                
                
                if imageIndex < 0 {
                    
                    imageIndex = maxImages
                    self.pageControl.currentPage = maxImages + 1
                    
                }
                                
                if imageIndex >= 0 {
                    imageView.image =  imageList[imageIndex]
                }
                
            case UISwipeGestureRecognizerDirection.Left:
                print("User swiped Left")
                
                // increase index first
                
                imageIndex += 1
                
                 self.pageControl.currentPage += 1
                
                // check if index is in range
                if imageIndex > maxImages {
                    imageIndex = 0
                    self.pageControl.currentPage = 0
                }
                
                if imageIndex <= imageList.count && imageList.count > 0 {
                    imageView.image = imageList[imageIndex]
                }
            default:
                break //stops the code/codes nothing.
                
                
            }
            
        }
        
        
    }
    
    

    
    @IBAction func addPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
        actionSheet.addAction(UIAlertAction(title: "Upload from Photo Library", style:.Default, handler: { action in
    
    
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            self.presentViewController(picker,animated: true, completion:nil)
    
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style:.Default, handler: { action in
    
    
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            self.presentViewController(picker,animated: true, completion:nil)
    
    
        }))
    
        actionSheet.addAction(UIAlertAction(title: "Cancel", style:.Cancel, handler: { action in
            print("No photo added")
    
        }))
    
    
        self.presentViewController(actionSheet, animated: true, completion: nil)
    
    }
 
 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let oldImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        var image = self.cropToBounds(oldImage!, width: 1000, height: 1000)
        let imageRandomName = NSUUID().UUIDString
        
        var picRef = storageRef.child(imageName!).child("\(imageRandomName).jpg")
        var imageData: NSData = UIImageJPEGRepresentation(image, 0)!
        let uploadTask = picRef.putData(imageData, metadata: nil) { metadata, error in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
                self.databaseRef.child("marketplace").child(self.imageName!).child("images").child(imageRandomName).setValue(FIRServerValue.timestamp())
                self.dismissViewControllerAnimated(true, completion: nil)
                self.imageList.append(image)
                self.maxImages += 1
                self.pageControl.numberOfPages += 1
                self.loadImages()
                
            }
        }
    }
 
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
 
   
    
    
    
    @IBOutlet weak var settingButton: UIButton!
    
    //changes the item's name, price and description
    @IBAction func settingButtonClicked(sender: AnyObject) {
        
    
            self.bookDescription.editable = true
            self.bookPrice.userInteractionEnabled = true
            self.bookName.userInteractionEnabled = true
        
        
            doneButton.hidden = false
            settingButton.hidden = true
    
    }
    
    //done editing item's name, price, and description
    
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        
        self.bookDescription.editable = false
        self.bookPrice.userInteractionEnabled = false
        self.bookName.userInteractionEnabled = false
        
        self.databaseRef.child("marketplace").child(imageName!).child("searchable").child("book name").setValue(bookName.text)
        self.databaseRef.child("marketplace").child(imageName!).child("price").setValue(bookPrice.text)
        self.databaseRef.child("marketplace").child(imageName!).child("searchable").child("description").setValue(bookDescription.text)
        
        doneButton.hidden = true
        settingButton.hidden = false
    }
    
    
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //hides keyboard when return is pressed for text field

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //hides keyboard when return is pressed for text view
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            if bookName.text != "" && bookPrice.text != "" {
                doneButton.hidden = false
            }
            
            if bookName.text == "" || bookPrice.text == "" {
                doneButton.hidden = true
            }
            return false
        }
        return true
    }

    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //changes the keyboard
    
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    //shift the screen when there is a keyboard
    func keyboardWillShow(sender: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                
                self.view.frame.origin.y -= keyboardSize.height
            }
        } else {
            
            self.view.frame.origin.y += keyboardSize.height - offset.height
        }
    }
    
    
    @IBAction func chatButton(sender: AnyObject) {
        
        let startChat = startNewChat()
        startChat.delegate = self
        startChat.userID = self.userID
        startChat.userName = self.userName
        startChat.startNewChat()
        
        
        
//        //NEED 4 things for this function to run
//        // 1- Current user's uid and name  && 2 - other user's uid and name
//        
//        
//        let thisUserId = FIRAuth.auth()?.currentUser?.uid
//        let thisUsername = FIRAuth.auth()?.currentUser?.displayName
//        
//        //NOTE this should be like otherUserId = self.otherUserId ( should be easily accesible if you are already showing the item by the user )
//        let otherUserId = self.userID
//        let otherUsername = self.userName
//        
//        var newChatId = "\(thisUserId!)&&\(otherUserId!)"
//        let otherNewChatId = "\(otherUserId!)&&\(thisUserId!)"
//        self.chatUID = newChatId
//        
//        
//        //uncomment this line or make a similar reference
//        let chatRootRef = FIRDatabase.database().reference().child("user")
//        
//        //Checking if the chat already exists
//        
//        chatRootRef.child(thisUserId!).child("chats").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {snapshot in
//            if snapshot.hasChild(newChatId) || snapshot.hasChild(otherNewChatId){
//                if snapshot.hasChild(otherNewChatId){
//                    newChatId = otherNewChatId
//                    self.chatUID = newChatId
//                }
//                //self.performSegueWithIdentifier("shortToChat", sender: self)
//                self.jiggyIntoChat()
//            }else{
//                let unreadMessage = [self.userID, "no" ]
//                
//                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastMessage").setValue("Hey")
//                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUID").setValue(otherUserId)
//                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUsername").setValue(otherUsername)
//                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("unread").setValue(unreadMessage as? AnyObject)
//                
//                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("lastMessage").setValue("Hey")
//                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("otherUID").setValue(thisUserId)
//                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("otherUsername").setValue(thisUsername)
//                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("unread").setValue(unreadMessage as? AnyObject)
//                
//                
//                //adding a new starter message by the person who started the chat
//                let chatRef = FIRDatabase.database().reference().child("chats")
//                chatRef.child(newChatId).child("0").child("senderId").setValue(thisUserId)
//                let dateformatter = NSDateFormatter()
//                dateformatter.timeZone = NSTimeZone(abbreviation: "GMT")
//                dateformatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
//                let dateString = dateformatter.stringFromDate(NSDate())
//                chatRef.child(newChatId).child("0").child("sentDate").setValue(dateformatter.stringFromDate(NSDate()))
//                chatRef.child(newChatId).child("0").child("text").setValue("Hey!")
//                
//                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("sentDate").setValue(dateString)
//                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("sentDate").setValue(dateString)
//                
//                let timeInterval = NSDate().timeIntervalSinceReferenceDate
//                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastUpdated").setValue(Int (timeInterval))
//                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("lastUpdated").setValue(Int (timeInterval))
//                
//                
//                //Let's jiggy into the chat view controller
//                
//                self.jiggyIntoChat()
//            }
//        })
    }
    
    func jiggyIntoChat(chatUID: String?){
        let barViewControllers = self.tabBarController?.viewControllers
        let destVC = barViewControllers![1] as! UINavigationController
        
        let chatVC = destVC.viewControllers.first as! ChatsTableViewController
        chatVC.fbUID = ""
        chatVC.firebaseUID = FIRAuth.auth()?.currentUser?.uid
        chatVC.userName = FIRAuth.auth()?.currentUser?.displayName
        chatVC.fromMarketPlace = true
        chatVC.chatUID = chatUID
        
        self.tabBarController?.selectedIndex = 1
    }
    
    
    
    
    
    @IBAction func goToOtherProfile(sender: AnyObject) {
        
        performSegueWithIdentifier("goToOtherProfile", sender: self)
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToOtherProfile" {
            
            
            let destinationVC = segue.destinationViewController as! UINavigationController
            let destVC = destinationVC.viewControllers[0] as! ProfileViewController
            destVC.userID = self.userID
            destVC.otherUser = true
             destVC.chatButtonHidden = true

        }
    }
    
    
    
    
 }
 
 


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


