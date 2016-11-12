//
//  ChatViewController.swift
//  ParseStarterProject
//
//  Created by Tarun Khasnavis on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Foundation
import MediaPlayer
import Parse
import STZPopupView
class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    //Must be set on segue
    var usernameText = ""
    var otherUserIds = Array<String>()
    var groupId: String = ""
    
    
    var timer: Timer = Timer()
    var isLoading: Bool = false
    
    
    
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    var senderImageUrl: String!
    var batchMessages = true
    var currChatObjects = Array<PFObject>()
    var allMessages = Array<String>()
    var chatUid = ""
    var usernames = Array<String>() //Current user's username is first in this array
    var profPics = Array<PFFile>() //Current user's profile picture is first in this array
    var twoProfPics = Array<PFFile>()
    var numImagesToSend = 0
    var sendingImages = false
    var otherUserObjectId = ""
    var lightColor = UIColor.gray
    var darkColor = UIColor.gray
    var gColor = UIColor.gray
    var popupView = UIView(frame: CGRect(x: 10, y: (UIScreen.main.bounds.height-400)/2, width: UIScreen.main.bounds.width - 20, height: 400))
    
    @IBOutlet weak var nameButton: UIButton!
    
    @IBAction func nameButtonPressed(_ sender: AnyObject) {
        if otherUserIds.count == 1 {
            self.performSegue(withIdentifier: "toViewProfile", sender: self)
        }
    }

 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(usernames.count)
        setupNavBar()
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        gColor = colorWithHexString ("#696969")
        
        
        self.collectionView?.backgroundColor = UIColor.clear
        
        
        self.senderId = PFUser.current()!.objectId
        self.senderDisplayName = PFUser.current()?.username
        
        outgoingBubbleImage = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImage = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "maleUser"), diameter: 30)
        
        isLoading = false
        self.loadMessages()
        Messages.clearMessageCounter(groupId)
        print("got username in here too")
        print(usernameText)
        nameButton.setTitle(usernameText, for: UIControlState())
        
        
    }
    func setupNavBar() {
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.tintColor = Constants.appBlueCOlor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewProfile" {
            if usernameText.range(of: ",") == nil {
                let destVC = segue.destination as! ViewableProfileTableViewController
                destVC.otherUserId = otherUserIds.first!
            }
        
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChatViewController.loadMessages), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        timer.invalidate()
    }
    
    func loadMessages() {
        
        if self.isLoading == false {
            self.isLoading = true
            let lastMessage = messages.last
            
            let query = PFQuery(className: "Messages")
            query.whereKey("groupId", equalTo: groupId)
            if lastMessage != nil {
                query.whereKey("createdAt", greaterThan: (lastMessage?.date)!)
            }
            query.includeKey("madeBy")
            query.order(byDescending: "createdAt")
            query.limit = 50
            
            query.findObjectsInBackground {
                (objects: [PFObject]?, error: Error?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    self.automaticallyScrollsToMostRecentMessage = false
                    for object in Array((objects as! [PFObject]!).reversed()) {
                        self.addMessage(object)
                    }
                    
                    print("the message count is")
                    print(objects!.count)
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottom(animated: false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true

                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!._userInfo)")
                }
                self.isLoading = false
            }
        }

        
      
        
    }
    
    
    func addMessage(_ object: PFObject) {
        var message: JSQMessage!
        
        var user = object["madeBy"] as! PFUser
        var name = PFUser.current()?.username
        
        var videoFile = object["videoFile"] as? PFFile
        var pictureFile = object["pictureFile"] as? PFFile
        
        print("the id is now")
        print(user.objectId)
        
        print("got in here when the content is")
        print(object["content"] as! String)
        
        if videoFile == nil && pictureFile == nil {
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object["content"] as? String))
        }
        
        if videoFile != nil {
            var mediaItem = JSQVideoMediaItem(fileURL: URL(string: videoFile!.url!), isReadyToPlay: true)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
        }
        
        if pictureFile != nil {
            var mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
            
            pictureFile!.getDataInBackground {
                (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        mediaItem?.image = UIImage(data: imageData)
                        print("getting in the right place")
                        self.collectionView!.reloadData()
                    }
                }
           
        }
            
        
        
            
        
        }
        users.append(user)
        messages.append(message)
        self.collectionView!.reloadData()
    }
    
    func sendMessage(_ text: String, video: URL?, picture: UIImage?) {
        var text = text
        var videoFile: PFFile!
        var pictureFile: PFFile!
        
        if let video = video {
            text = "[Video]"
            videoFile = PFFile(name: "video.mp4", data: FileManager.default.contents(atPath: video.path)!)
            videoFile.saveInBackground(withTarget: nil, selector: nil)
        }
        
        if let picture = picture {
            text = "[Picture message]"
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            pictureFile.saveInBackground(withTarget: nil, selector: nil)
        }
        
        let object = PFObject(className: "Messages")
        object["madeBy"] = PFUser.current()
        print("the group id is")
        print(self.groupId)
        object["groupId"] = self.groupId
        object["content"] = text
        object["counter"] = 0
        
        if let videoFile = videoFile {
            object["videoFile"] = videoFile
        }
        if let pictureFile = pictureFile {
            object["pictureFile"] = pictureFile
        }
        
        object.saveInBackground {
            (success: Bool, error: Error?) -> Void in
            if (success) {
                // The object has been saved.
                self.loadMessages()
            } else {
                // There was a problem, check error.description
            }
        }
        
        var query = PFQuery(className:"Chats")
        print("right id is")
        print(groupId)
        query.whereKey("objectId", equalTo: groupId)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object["showChat"] != nil {
                            object["lastMessage"] = text
                            object["lastMessageFrom"] = PFUser.current()?.objectId
                            let showChat = object["showChat"] as! Bool
                            if showChat == false {
                                print("got to this right point")
                                object["showChat"] = true
                            }
                            object.saveInBackground(withTarget: nil, selector: nil)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!._userInfo)")
            }
        }
        
        Messages.updateMessageCounter(groupId, lastMessage: text)
        
        self.finishSendingMessage()
        
        }
    
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        //Check that the user isn't sending a blank message
        let whitespaceSet = CharacterSet.whitespaces
        if text.trimmingCharacters(in: whitespaceSet) != "" {
            sendMessage(text, video: nil, picture: nil)
        }

    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let action = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take photo", "Choose existing photo", "Choose existing video")
        action.show(in: self.view)
    }
    
    // MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        print("message text is")
        print(self.messages[indexPath.row].text)
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        var user = self.users[indexPath.item]
        if self.avatars[user.objectId!] == nil {
            var thumbnailFile = user["profilePicture"] as? PFFile
            thumbnailFile!.getDataInBackground {
                (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.avatars[user.objectId! as String] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: imageData), diameter: 30)
                        self.collectionView!.reloadData()

                    }
                }
            }
            return blankAvatarImage
        } else {
            return self.avatars[user.objectId!]
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: - UICollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("the count is")
        print(self.messages.count)
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = self.messages[(indexPath as NSIndexPath).item]
        if message.senderId == self.senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    // MARK: - UICollectionView flow layout
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0
    }
    
    // MARK: - Responding to CollectionView tap events
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        print("didTapAvatarImageview")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = self.messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let moviePlayer = MPMoviePlayerViewController(contentURL: mediaItem.fileURL)
                self.presentMoviePlayerViewControllerAnimated(moviePlayer)
                moviePlayer?.moviePlayer.play()
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            if buttonIndex == 1 {
//                Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
            } else if buttonIndex == 2 {
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = UIImagePickerControllerSourceType.photoLibrary
                image.allowsEditing = false
                self.present(image, animated: true, completion: nil)
            } else if buttonIndex == 3 {
//                Camera.shouldStartVideoLibrary(self, canEdit: true)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let video = info[UIImagePickerControllerMediaURL] as? URL
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.sendMessage("", video: video, picture: picture)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if messages.last?.senderId != PFUser.current()?.username {
            let query = PFQuery(className:"Chats")
            query.whereKey("objectId", equalTo:chatUid)
            query.findObjectsInBackground {
                (objects: [PFObject]?, error: Error?) -> Void in
                
                if error == nil {
                    print("Successfully retrieved \(objects!.count) scores.")
                    if let objects = objects {
                        for object in objects {
                            object["lastMessageFrom"] = self.title!
                            object["lastMessageSeen"] = true
                            object.saveInBackground(withTarget: nil, selector: nil)
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!._userInfo)")
                }
            }
        }
    }
    
    @IBAction func dismissVC(_ sender: AnyObject) {
       
        if messages.last?.senderId != PFUser.current()?.objectId  && messages.last?.text != "" && messages.last?.text != nil {
            let query = PFQuery(className:"Chats")
            query.whereKey("objectId", equalTo:groupId)
            query.findObjectsInBackground {
                (objects: [PFObject]?, error: Error?) -> Void in
                
                if error == nil {
                    print("Successfully retrieved \(objects!.count) scores.")
                    if let objects = objects {
                        for object in objects {
                            object["lastMessageFrom"] = self.messages.last!.senderId
                            object["lastMessageSeen"] = true
                            object.saveInBackground(withTarget: nil, selector: nil)
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!._userInfo)")
                }
            }
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Creates a UIColor from a Hex string.
    func colorWithHexString (_ hex:String) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    @IBAction func openFlagModal(_ sender: AnyObject) {
        var subtitleText = "Are you sure you want to flag this user for objectionable content? We will then review the content and see if anything inappropriate should be removed."
        
        var popupTitleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width - 40, height: 40))
        var popupOkayButton = UIButton()
        var popupSubtitleLabel = UILabel()
        popupTitleLabel.font = UIFont(name: "American Typewriter", size: 20)
        popupTitleLabel.textColor = Constants.lightGreenColor
        popupTitleLabel.textAlignment = .center
        popupTitleLabel.text = "Flag Post"
        popupSubtitleLabel.font = UIFont(name: "American Typewriter", size: 15)
        popupSubtitleLabel.text = subtitleText
        popupSubtitleLabel.adjustsFontSizeToFitWidth = true
        let a = popupSubtitleLabel.text?.characters.count
        let b = 30
        var numLines = (a! + b - 1)/(b)
        popupSubtitleLabel.numberOfLines = numLines
        popupSubtitleLabel.frame = CGRect(x: 10, y: 45, width: Int(UIScreen.main.bounds.width) - 40, height: numLines*20)
        var popupViewHeight = 10 + popupTitleLabel.frame.height + 5 + popupSubtitleLabel.frame.height + 10 + 40 + 10
        popupView.frame = CGRect(x: 10, y: (UIScreen.main.bounds.height-popupViewHeight)/2, width: UIScreen.main.bounds.width - 20, height: popupViewHeight)
        popupOkayButton.frame = CGRect(x: 10, y: popupView.frame.height - 50, width: popupView.frame.width - 20, height: 40)
        popupOkayButton.setTitle("YES, FLAG POST", for: UIControlState())
        popupOkayButton.setTitleColor(UIColor.white, for: UIControlState())
        popupOkayButton.titleLabel?.textColor = Constants.lightGreenColor
        popupOkayButton.titleLabel!.font = UIFont(name: "Gujarati Sangam MN", size: 20)
        popupOkayButton.backgroundColor = Constants.lightGreenColor
        popupOkayButton.layer.cornerRadius = 5
        popupOkayButton.addTarget(self, action: #selector(ChatViewController.flagPost), for: .touchUpInside)
        popupView.backgroundColor = UIColor.white
        popupView.addSubview(popupTitleLabel)
        popupView.addSubview(popupSubtitleLabel)
        popupView.addSubview(popupOkayButton)
        popupView.bringSubview(toFront: popupOkayButton)
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        popupConfig.showCompletion = { popupView in
            
        }
        popupConfig.dismissCompletion = { popupView in
            popupTitleLabel.removeFromSuperview()
            popupSubtitleLabel.removeFromSuperview()
            popupOkayButton.removeFromSuperview()
            
        }
        
        presentPopupView(popupView, config: popupConfig)
    }
    
    func flagPost() {
        let query = PFQuery(className:"Chats")
        query.whereKey("objectId", equalTo: chatUid)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    var currFlags = objects.first!["flags"] as! Int
                    currFlags = currFlags + 1
                    objects.first!["flags"] = currFlags
                    objects.first?.saveInBackground(withTarget: nil, selector: nil)

                }
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!._userInfo)")
            }
        }
        
        
        dismissPopupView()
    }
    
 

}
