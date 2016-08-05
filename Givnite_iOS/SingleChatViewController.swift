/*
 +* Copyright (c) 2015 Razeware LLC
 +*
 +* Permission is hereby granted, free of charge, to any person obtaining a copy
 +* of this software and associated documentation files (the "Software"), to deal
 +* in the Software without restriction, including without limitation the rights
 +* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 +* copies of the Software, and to permit persons to whom the Software is
 +* furnished to do so, subject to the following conditions:
 +*
 +* The above copyright notice and this permission notice shall be included in
 +* all copies or substantial portions of the Software.
 +*
 +* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 +* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 +* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 +* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 +* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 +* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 +* THE SOFTWARE.
 +*/

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FBSDKCoreKit
import JSQMessagesViewController

class SingleChatViewController: JSQMessagesViewController {
    
    
    //Note for future: Cannot currently "smartly" delete sent messages
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    let rootRef = FIRDatabase.database().reference()
    var messageRef = FIRDatabaseReference()
    var newMessageRef = FIRDatabaseReference()
    var chatUID : String?
    var otherUID: String?
    var otherUsername: String?
    var fromMarketPlace = false
    
    var alreadyAppeared = false;
    
    let newDateFormatter = NSDateFormatter()
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    //var logoutDelegate : pseudoLogout?
    
    //For user is typing
    
    var userIsTyping = FIRDatabase.database().reference()
    private var localTyping = false
    var isTyping:Bool{
        get{
            return localTyping
        }set{
            localTyping =  newValue
            userIsTyping.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup date formatter
        self.newDateFormatter.timeZone = NSTimeZone.localTimeZone()
        self.newDateFormatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
        
        print(chatUID)
        
        setupBubbles()
        //        let collectionViewBounds = collectionView?.bounds
        //        collectionView?.frame = CGRectMake(0.0, 44.0, (collectionViewBounds?.width)!, (collectionViewBounds?.height)!)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        collectionView?.reloadData()
        
        messageRef = rootRef.child("chats").child(chatUID!)
        
        let chatRef = rootRef.child("user").child(senderId).child("chats").child(chatUID!)
        
        
        self.navigationItem.leftBarButtonItem?.title = "back"
        
        let givniteColor = UIColor(colorLiteralRed: 255/255, green: 80/255, blue: 85/255, alpha: 1)
        self.navigationController!.navigationBar.tintColor = givniteColor
        
        
        chatRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) -> Void in
            let snapshotDict = snapshot.valueInExportFormat() as? NSDictionary
            self.otherUID = snapshotDict?.valueForKey("otherUID") as? String
            print(self.otherUID)
            self.otherUsername = snapshotDict?.valueForKey("otherUsername") as? String
            self.title = self.otherUsername
            
            let unread = snapshotDict?.valueForKey("unread") as! NSDictionary
            
            if unread.valueForKey("0") as? String == self.otherUID {
                chatRef.child("unread").child("1").setValue("no")
            }
        })
        
        
        
        
        self.inputToolbar?.contentView?.leftBarButtonItem = nil;
        
        //                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "backPressed")
        //
        //  let screenWidth = UIScreen.mainScreen().bounds.size.width
        //
        //  let navigationBar = UINavigationBar(frame: CGRectMake(0,22,screenWidth,44))
        //  navigationBar.backgroundColor = UIColor.orangeColor()
        //
        //  let navigationItem = UINavigationItem()
        //  navigationItem.title = "Chat"
        //
        //        let leftButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "backPressed")
        //
        //        navigationItem.leftBarButtonItem = leftButton
        //        navigationBar.items = [navigationItem]
        //
        //        self.view.addSubview(navigationBar)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if alreadyAppeared==false{
            observeMessages()
            observeTyping()
        }
        
        alreadyAppeared = true;
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupBubbles(){
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor(red: (255/255.0), green: (80/255.0), blue: (85/255.0), alpha: 1.0))
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0){
            let message = messages[indexPath.item]
            print("loadingTimestamp")
            //print(JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date))
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }else{
            return nil
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0{
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    //The date's are added as current dates. This is done under the assumption everyone will be in new york and there will be no time difference
    
    func addMessage(id:String, text: String, date: String){
        var message = JSQMessage?()
        //        let dateFormatter = NSDateFormatter()
        //        //dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        //        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
        //        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        //print(dateFormatter.dateFromString(date))
        
        if id==self.senderId{
            message = JSQMessage(senderId: id, senderDisplayName: senderDisplayName, date: self.newDateFormatter.dateFromString(date), text: text)
        }else if id==self.otherUID{
            message = JSQMessage(senderId: otherUID, senderDisplayName: otherUsername, date: self.newDateFormatter.dateFromString(date), text: text)
        }
        
        //let messageWithTime = JSQMessage(senderId: id, senderDisplayName: , date: <#T##NSDate!#>, text: <#T##String!#>)
        messages.append(message!)
        
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.child("\(messages.count)")
        let dateformatter = NSDateFormatter()
        //dateformatter.locale = NSLocale(localeIdentifier: "en_US")
        //dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateformatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
        let dateString = dateformatter.stringFromDate(NSDate())
        
        print("look at this")
        print(NSDate())
        let messageItem = [
            "text":text,
            "senderId":senderId,
            "sentDate":dateString
        ]
        
        itemRef.setValue(messageItem);
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let unreadMessage = [senderId,"yes"]
        
        rootRef.child("user").child(senderId).child("chats").child(chatUID!).child("lastMessage").setValue(text)
        rootRef.child("user").child(senderId).child("chats").child(chatUID!).child("unread").setValue(unreadMessage)
        rootRef.child("user").child(otherUID!).child("chats").child(chatUID!).child("lastMessage").setValue(text)
        rootRef.child("user").child(otherUID!).child("chats").child(chatUID!).child("unread").setValue(unreadMessage)
        rootRef.child("user").child(otherUID!).child("chats").child(chatUID!).child("sentDate").setValue(dateString)
        rootRef.child("user").child(senderId).child("chats").child(chatUID!).child("sentDate").setValue(dateString)
        
        let timeInterval = NSDate().timeIntervalSinceReferenceDate
        rootRef.child("user").child(otherUID!).child("chats").child(chatUID!).child("lastUpdated").setValue(Int (timeInterval))
        rootRef.child("user").child(senderId).child("chats").child(chatUID!).child("lastUpdated").setValue(Int (timeInterval))
        
        finishSendingMessage()
        finishSendingMessage()
        isTyping = false
        
    }
    
    private func observeMessages(){
        let messageQuery = messageRef.queryLimitedToLast(300)
        
        messageQuery.observeEventType(FIRDataEventType.ChildAdded) { (snapshot: FIRDataSnapshot!) -> Void in
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            let sendDate = snapshot.value!["sentDate"] as! String
            
            self.addMessage(id, text: text, date: sendDate)
            
            self.finishReceivingMessage()
        }
    }
    
    
    var userTypingQuery : FIRDatabaseQuery!
    
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTyping = typingIndicatorRef.child(senderId)
        userIsTyping.onDisconnectRemoveValue()
        
        // 1
        userTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        
        userTypingQuery.observeEventType(FIRDataEventType.Value) { (snapshot:FIRDataSnapshot) -> Void in
            if snapshot.childrenCount == 1 && self.isTyping{
                return
            }
            
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
        
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindToTable", sender: self)
    }
    func backPressed(){
        self.performSegueWithIdentifier("unwindToTable", sender: self)
    }
    
    //Running a query for typing users
    
    
    
    
    
}