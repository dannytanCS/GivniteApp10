//
//  startNewChat.swift
//  Givnite_iOS
//
//  Created by Parth Bhardwaj on 8/4/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol letsJiggyDelegate : class{
    func jiggyIntoChat(chatUID: String?)
}

class startNewChat: NSObject {
    
    var userID: String?
    var userName: String?
    var chatUID:String?
    
    weak var delegate : letsJiggyDelegate?
    
    func startNewChat(){
        //NEED 4 things for this function to run
        // 1- Current user's uid and name  && 2 - other user's uid and name
        
        
        let thisUserId = FIRAuth.auth()?.currentUser?.uid
        let thisUsername = FIRAuth.auth()?.currentUser?.displayName
        
        //NOTE this should be like otherUserId = self.otherUserId ( should be easily accesible if you are already showing the item by the user )
        let otherUserId = self.userID
        let otherUsername = self.userName
        
        var newChatId = "\(thisUserId!)&&\(otherUserId!)"
        let otherNewChatId = "\(otherUserId!)&&\(thisUserId!)"
        self.chatUID = newChatId
        
        
        //uncomment this line or make a similar reference
        let chatRootRef = FIRDatabase.database().reference().child("user")
        
        //Checking if the chat already exists
        
        chatRootRef.child(thisUserId!).child("chats").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {snapshot in
            if snapshot.hasChild(newChatId) || snapshot.hasChild(otherNewChatId){
                if snapshot.hasChild(otherNewChatId){
                    newChatId = otherNewChatId
                    self.chatUID = newChatId
                }
                //self.performSegueWithIdentifier("shortToChat", sender: self)
                //self.jiggyIntoChat()
                self.delegate?.jiggyIntoChat(newChatId)
            }else{
                let unreadMessage = [self.userID, "yes" ]
                
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastMessage").setValue("Hey")
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUID").setValue(otherUserId)
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("otherUsername").setValue(otherUsername)
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("unread").setValue(unreadMessage as? AnyObject)
                
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("lastMessage").setValue("Hey")
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("otherUID").setValue(thisUserId)
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("otherUsername").setValue(thisUsername)
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("unread").setValue(unreadMessage as? AnyObject)
                
                
                //adding a new starter message by the person who started the chat
                let chatRef = FIRDatabase.database().reference().child("chats")
                chatRef.child(newChatId).child("0").child("senderId").setValue(thisUserId)
                let dateformatter = NSDateFormatter()
                dateformatter.timeZone = NSTimeZone(abbreviation: "GMT")
                dateformatter.dateFormat = "MMM dd, yyyy HH:mm zzz"
                let dateString = dateformatter.stringFromDate(NSDate())
                chatRef.child(newChatId).child("0").child("sentDate").setValue(dateformatter.stringFromDate(NSDate()))
                chatRef.child(newChatId).child("0").child("text").setValue("Hey!")
                
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("sentDate").setValue(dateString)
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("sentDate").setValue(dateString)
                
                let timeInterval = NSDate().timeIntervalSinceReferenceDate
                chatRootRef.child(thisUserId!).child("chats").child(newChatId).child("lastUpdated").setValue(Int (timeInterval))
                chatRootRef.child(otherUserId!).child("chats").child(newChatId).child("lastUpdated").setValue(Int (timeInterval))
                
                
                //Let's jiggy into the chat view controller
                
                //self.jiggyIntoChat()
                self.delegate?.jiggyIntoChat(newChatId)
            }
        })
    }
    
}