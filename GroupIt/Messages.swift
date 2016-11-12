//
//  Messages.swift
//  GroupIt
//
//  Created by Akkshay Khoslaa on 4/23/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import Foundation
import Parse
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class Messages {
    
    class func startPrivateChat(_ user1: PFUser, user2: PFUser) -> String {
        let id1 = user1.objectId
        let id2 = user2.objectId
        
        let groupId = (id1 < id2) ? "\(id1)\(id2)" : "\(id2)\(id1)"
        
        createMessageItem(user1, groupId: groupId, description: user2[(PFUser.current()?.username)!] as! String)
        createMessageItem(user2, groupId: groupId, description: user1[(PFUser.current()?.username)!] as! String)
        
        return groupId
    }
    
    class func startMultipleChat(_ users: [PFUser]!) -> String {
        var groupId = ""
        var description = ""
        
        var userIds = [String]()
        
        for user in users {
            userIds.append(user.objectId!)
        }
        
        let sorted = userIds.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        for userId in sorted {
            groupId = groupId + userId
        }
        
        for user in users {
            if description.characters.count > 0 {
                description = description + " & "
            }
            description = description + (user[(PFUser.current()?.username)!] as! String)
        }
        
        for user in users {
            Messages.createMessageItem(user, groupId: groupId, description: description)
        }
        
        return groupId
    }
    
    class func createMessageItem(_ user: PFUser, groupId: String, description: String) {
        let query = PFQuery(className: "Messages")
        query.whereKey("madeBy", equalTo: user)
        query.whereKey("groupId", equalTo: groupId)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    if objects.count == 0 {
                        let message = PFObject(className: "Messages")
                        message["madeBy"] = user;
                        message["groupId"] = groupId;
                        message["content"] = description;
                        message["lastUser"] = PFUser.current()
                        message["lastMessage"] = "";
                        message["counter"] = 0
//                        message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                        message.saveInBackground(withTarget: nil, selector: nil)
                    }
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    class func deleteMessageItem(_ message: PFObject) {
        
        message.deleteInBackground(withTarget: nil, selector: nil)
    }
    
    class func updateMessageCounter(_ groupId: String, lastMessage: String) {
        let query = PFQuery(className: "Messages")
        query.whereKey("groupId", equalTo: groupId)
        query.limit = 1000
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for message in objects as! [PFObject]! {
                        let user = message["madeBy"] as! PFUser
                        if user.objectId != PFUser.current()!.objectId {
                            message.incrementKey("counter") // Increment by 1
                            message["lastUser"] = PFUser.current()
                            message["lastMessage"] = lastMessage
//                            message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                            message.saveInBackground(withTarget: nil, selector: nil)
                        }
                    }

                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    class func clearMessageCounter(_ groupId: String) {
        let query = PFQuery(className: "Messages")
        query.whereKey("groupId", equalTo: groupId)
        query.whereKey("madeBy", equalTo: PFUser.current()!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for message in objects as! [PFObject]! {
                        message["counter"] = 0
                        message.saveInBackground(withTarget: nil, selector: nil)
                    }

                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
}
