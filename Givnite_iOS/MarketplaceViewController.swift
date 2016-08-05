//
//  MarketplaceViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/16/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, dropAndChat  {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarText: UISearchBar!
    

  

    let dataRef = FIRDatabase.database().referenceFromURL("https://givnite-ios.firebaseio.com/")
    
    let storageRef = FIRStorage.storage().referenceForURL("gs://givnite-ios.appspot.com")
    let user = FIRAuth.auth()?.currentUser
    var imageNameArray = [String]()
    var imageArray = [UIImage]()
    
    var bookNameArray = [String]()
    var bookPriceArray = [String]()
    var userArray = [String]()
    var descriptionArray = [String]()
    
    var refreshControl: UIRefreshControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Set Corner Radius of the view
      
      
        
        
        
        
        
        
        
        
        if let array = NSCache.sharedInstance.objectForKey("imageNameArray") as? [String] {
            imageNameArray = array
        }
        
        
        if searchBarText.text == "" {
            print(123123)
            refreshControlFunc()
        }
        
        loadImages()
        
//        let swipeLeftGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "unwindToProfile")
//        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
//        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
        
        searchBarText.delegate = self
        
        if let search = NSCache.sharedInstance.objectForKey("search") as? String {
            searchBarText.text = search
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -200 {
            scrollView.contentOffset = CGPointMake(0, -200)
        }
    }

    
    //refresh control
    
    func refreshControlFunc() {
        
        refreshControl = UIRefreshControl()
        refreshControl.bounds = CGRectMake(0, -5, refreshControl.bounds.size.width, refreshControl.bounds.size.height)
        collectionView.alwaysBounceVertical = true
        //refreshControl.attributedTitle = NSAttributedString(string: "Refreshing!")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.scrollEnabled = (collectionView.contentSize.height <= CGRectGetHeight(collectionView.frame));
        
        
        }
    

    
    func refresh(){
        
        NSCache.sharedInstance.removeObjectForKey("imageNameArray")
        imageNameArray.removeAll()
           // Updating your data here...
        
        
            searchBarText.text = ""
            loadImages()
        
        // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
        // This is where you'll make requests to an API, reload data, or process information
        var delayInSeconds = 2.0;
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    //clear everything
    
    func clear() {
        
        self.imageArray.removeAll()
        
        self.userArray.removeAll()
        self.bookNameArray.removeAll()
        self.bookPriceArray.removeAll()
        self.descriptionArray.removeAll()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.characters.count == 0) {
            searchBar.performSelector("resignFirstResponder", withObject: nil, afterDelay: 0.1)

            NSCache.sharedInstance.removeObjectForKey("imageNameArray")
            NSCache.sharedInstance.removeObjectForKey("search")
            self.imageNameArray.removeAll()
            viewDidLoad()
        }
    
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
      
        dataRef.child("user").child(user!.uid).child("query").setValue(searchBarText.text)
        searchBarText.resignFirstResponder()
        NSCache.sharedInstance.removeObjectForKey("search")
        NSCache.sharedInstance.setObject(searchBarText.text!, forKey: "search")
        dataRef.child("user").child(user!.uid).child("queryres").observeEventType(.ChildChanged, withBlock: {(snapshot) -> Void in
            self.updateTheCell()
        })
        self.updateTheCell()
    }

    
    func updateTheCell(){
        dataRef.child("user").child(user!.uid).child("queryres").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            NSCache.sharedInstance.removeObjectForKey("imageNameArray")
        
            if let topSearches = snapshot.value! as? NSArray {

                self.imageNameArray.removeAll()
             
                for imageName in topSearches {
                    if let name = imageName as? String {
                        self.imageNameArray.append(name)
                        
                    }
                }
            }
            self.viewDidLoad()
        })
    }
    
    //layout for cell size
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 2 ) / 2, height: (collectionView.frame.size.width + 80) / 2  )
    }


    func loadImages() {
        clear()
        dataRef.child("marketplace").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            if let itemDictionary = snapshot.value! as? NSDictionary {
            
                if let array = NSCache.sharedInstance.objectForKey("imageNameArray") as? [String] {
                    self.imageNameArray = array
                }
            
                    //adds image name from firebase database to an array
            
                else {
                    
                    if self.imageNameArray.count == 0{
                   
                        var timeArray = [Int]()
                    
                        for key in itemDictionary.allKeys {
                            if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                                if let time = keyDictionary["time"] {
                                    let time2 = time as! Int
                                    timeArray.append(time2)
                                }
                            }
                        }
                        timeArray = timeArray.sort().reverse()
                    
                    
                        for time in timeArray {
                            for key in itemDictionary.allKeys {
                                 if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                                    if let time2 = keyDictionary["time"]{
                                        if time == time2 as! Int {
                                            self.imageNameArray.append("\(key)")
                                            if let searchable = keyDictionary["searchable"] as? NSDictionary    {
                                                if let bookName = searchable["book name"] as? String {
                                                    self.bookNameArray.append(bookName)
                                                }
                                                else {
                                                    self.bookNameArray.append("")
                                                }
                                                if let bookDescription  = searchable["description"] as? String {
                                                    self.descriptionArray.append(bookDescription)
                                                }
                                                else {
                                                    self.descriptionArray.append("")
                                                }
                                            }
                                            else {
                                                self.bookNameArray.append("")
                                                self.descriptionArray.append("")
                                            }
                                            if let bookPrice = keyDictionary["price"] as? String {
                                                self.bookPriceArray.append(bookPrice)
                                            }
                                            else {
                                                self.bookPriceArray.append("")
                                            }
                                            if let userID = keyDictionary["user"] as? String {
                                                self.userArray.append(userID)
                                            }
                                        
                                        }
                                    
                                    }
                                }
                            }
                        }
                    }
                }

                for image in self.imageNameArray {
                    
                    if self.imageNameArray.count != 0 {
                        if let keyDictionary = itemDictionary[image] as? NSDictionary {
                            if let searchable = keyDictionary["searchable"] as? NSDictionary {
                                if let bookName = searchable["book name"] as? String {
                                    self.bookNameArray.append(bookName)
                                }
                                else {
                                    self.bookNameArray.append("")
                                }
                                if let bookDescription  = searchable["description"] as? String {
                                    self.descriptionArray.append(bookDescription)
                                }
                                else {
                                    self.descriptionArray.append("")
                                }
                            }
                            else {
                                self.bookNameArray.append("")
                                self.descriptionArray.append("")
                            }
                            if let bookPrice = keyDictionary["price"] as? String {
                                self.bookPriceArray.append(bookPrice)
                            }
                            else {
                                self.bookPriceArray.append("")
                            }
                            if let userID = keyDictionary["user"] as? String {
                                self.userArray.append(userID)
                            }
                        }
                    }
                }
            }
            for index in 0..<self.imageNameArray.count {
                self.imageArray.append(UIImage(named: "Examples")!)
            }
            
            NSCache.sharedInstance.setObject(self.imageNameArray, forKey: "imageNameArray")

            
        
            dispatch_async(dispatch_get_main_queue(),{
                self.collectionView.reloadData()
            })
        })
        
    }

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNameArray.count
    }
    
    
    var priceCache = [String:String]()
    var bookCache = [String:String]()
 
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!
        MarketCollectionViewCell
        
        if imageArray.count > indexPath.row {
            if let imageName = self.imageNameArray[indexPath.row] as? String {
                cell.itemImageView.image = nil
                
               
                if let image = NSCache.sharedInstance.objectForKey(imageName) as? UIImage {
                    cell.itemImageView.image = image
                    if imageArray.count > indexPath.row {
                        self.imageArray[indexPath.row] = image
                    }
                }
                    
                else { 
                    var imagesRef = storageRef.child(imageName).child("\(imageName).jpg")
                    //sets the image on profile
                    imagesRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                            print ("File does not exist")
                            return
                        } else {
                            if (data != nil){
                                let imageToCache = UIImage(data:data!)
                                NSCache.sharedInstance.setObject(imageToCache!, forKey: imageName)
                                dispatch_async(dispatch_get_main_queue(),{
                                    cell.itemImageView.image = imageToCache
                                    if self.imageArray.count > indexPath.row {
                                        self.imageArray[indexPath.row] = imageToCache!
                                    }
                                })
                            }
                        }
                        }.resume()
                    
                }
                
                
                if userArray.count > indexPath.row {
                    
                    let userID = userArray[indexPath.row]
                    cell.profileImageButton.layer.cornerRadius =  cell.profileImageButton.bounds.size.width/2
                    cell.profileImageButton.clipsToBounds = true
                    
                    
                    var maskPath: UIBezierPath = UIBezierPath(roundedRect: cell.itemDescriptionView.bounds, byRoundingCorners: ([.TopLeft, .TopRight]), cornerRadii: CGSizeMake(5.0, 5.0))
                    var maskLayer: CAShapeLayer = CAShapeLayer()
                    maskLayer.frame = self.view.bounds
                    maskLayer.path = maskPath.CGPath
                    cell.itemDescriptionView.layer.mask = maskLayer
                    
                    
                    
                    
                    
                    if let userImage = NSCache.sharedInstance.objectForKey(userID) as? UIImage {
                        
                        cell.profileImageButton.setImage(userImage, forState: .Normal)
                    }
                        
                    else {
                        var profilePicRef = storageRef.child(userID).child("profile_pic.jpg")
                        
                        
                        //sets the image on profile
                        profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                            if (error != nil) {
                                print ("File does not exist")
                                
                                return
                            } else {
                                if (data != nil){
                                    let imageToCache = UIImage(data:data!)
                                    NSCache.sharedInstance.setObject(imageToCache!, forKey: userID)
                                    dispatch_async(dispatch_get_main_queue(),{
                                        cell.profileImageButton.setImage(imageToCache!, forState: .Normal)
                                    })
                                    
                                }
                            }
                            }.resume()
                    }
                }
                if let bookName = bookCache[imageName] {
                    cell.bookName.text = bookName
                
                }
                else {
                    if bookNameArray.count > indexPath.row {
                        let bookNameToCache = bookNameArray[indexPath.row]
                        self.bookCache[imageName] = bookNameToCache
                        cell.bookName.text = bookNameToCache
                    }
                }
                if let bookPrice = priceCache[imageName] {
                    cell.bookPrice.text = "$" + bookPrice
                }
                
                else {
                    if bookPriceArray.count > indexPath.row {
                        let bookPriceToCache = bookPriceArray[indexPath.row]
                        self.priceCache[imageName] = bookPriceToCache
                        cell.bookPrice.text = bookPriceToCache
                    }
                }

            }
        }
        
        
        cell.profileImageButton.addTarget(self, action: "profileImageButtonClicked:", forControlEvents: .TouchUpInside)
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("marketEnlarge", sender: self)
    }

    @IBAction func profileImageButtonClicked(sender: UIButton) {
        let point = collectionView.convertPoint(CGPointZero, fromView: sender)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            self.userID = self.userArray[indexPath.row]
            if let string = self.userArray[indexPath.row] as? String {
                
                self.performSegueWithIdentifier("showProfile", sender: self)
                //self.otherUserProfile()
                
            }
        }
    }
    
    func otherUserProfile(){
        let barViewControllers = self.tabBarController?.viewControllers
        let destVC = barViewControllers![2] as! UINavigationController
        
        let profileVC = destVC.viewControllers.first as! ProfileViewController
        profileVC.userID = self.userID
        profileVC.otherUser = true
        
        self.tabBarController?.selectedIndex = 2
    }
    
    func chatAfterDismiss(chatUID:String){
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
    
    var userID: String?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "marketEnlarge" {
            let destinationVC = segue.destinationViewController as! ItemViewController
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            destinationVC.imageName = self.imageNameArray[indexPath.row]
            destinationVC.image = self.imageArray[indexPath.row]
            destinationVC.otherUser = true
            destinationVC.userID = self.userArray[indexPath.row]
        }
        
        else if segue.identifier == "showProfile" {
            
            
            //let tabBarVC = segue.destinationViewController as! UITabBarController
            let destinationVC = segue.destinationViewController as! UINavigationController
            let destVC = destinationVC.viewControllers[0] as! ProfileViewController
            destVC.dismissDelegate = self
            destVC.userID = self.userID
            destVC.otherUser = true
           
            
            

        }
    }
}