//
//  ChatsTableViewController.swift
//  ParseStarterProject
//
//  Created by Tarun Khasnavis on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import STZPopupView
class ChatsTableViewController: UITableViewController, UISearchBarDelegate {

    
    var allUsers = Array<PFObject>()
    var chatObjects = Array<PFObject>()
    var currChatUsers = Array<PFObject>()
    var idToUser = Dictionary<String, PFObject>()
    var usernameTextToPass = ""
    var searchBar = UISearchBar()
    var searchBarText = ""
    var debounceTimer: Timer?
    var currChatIndex = 0
    var refresher:UIRefreshControl!
    var takeDirect = false
    var lightColor = UIColor.gray
    var darkColor = UIColor.gray
    var gColor = UIColor.gray
    var selectedGroupId = ""
    var usersToAdd = Array<String>()
    var chatObjectToPass:PFObject?
    
    
    var usersTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 250))
     var popupView = UIView(frame: CGRect(x: 10, y: (UIScreen.main.bounds.height-400)/2, width: UIScreen.main.bounds.width - 20, height: 400))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        gColor = colorWithHexString ("#696969")
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:#selector(ChatsTableViewController.refresh), for:UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        setupNavBar()
        setupTableView()
        getChats()
        getUsers()
    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.barTintColor = Constants.appBlueCOlor
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Helvetica", size: 20)!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.title = "Chats"
    }
    
    func getChats() {
        
        let query = PFQuery(className:"Chats")
        query.whereKey("groupUsers", containsAllObjectsIn: [(PFUser.current()?.objectId)!])
        query.whereKey("showChat", equalTo: true)
        query.order(byDescending: "updatedAt")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.chatObjects = objects
                        
                        var userObjectIds = Array<String>()
                        for chatObject in self.chatObjects {
                            let currUserIds = chatObject["groupUsers"] as! Array<String>
                            
                            for id in currUserIds {
                                userObjectIds.append(id)
                            }
                        }
                        
                        self.getRelevantUsers(userObjectIds)
                        
                        
                    }
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    func getRelevantUsers(_ userObjectIds: Array<String>) {
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", containedIn: userObjectIds)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    self.currChatUsers = objects
                    for object in objects {
                        self.idToUser[object.objectId!] = object
                    }
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == usersTableView {
            return allUsers.count
        }
        return self.chatObjects.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == usersTableView {
            return 50
        }
        
        return 70
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == usersTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            
            if usersToAdd.contains(allUsers[(indexPath as NSIndexPath).row].objectId!) == true {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            cell.awakeFromNib()
            
            cell.usernameLabel!.text = allUsers[(indexPath as NSIndexPath).row]["username"] as! String
            
            MDBSwiftParseUtils.setImageViewImageFromFile(allUsers[(indexPath as NSIndexPath).row]["profilePicture"] as! PFFile, imageView: cell.profPicImageView)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatsCell", for: indexPath) as! ChatsTableViewCell
            
            
            //Cell UI formatting
            cell.backgroundColor = UIColor.white
            cell.daysAgo.textColor = Constants.greenColor
            cell.daysAgo.font = UIFont.systemFont(ofSize: 10)
            cell.username.font = UIFont.systemFont(ofSize: 14)
            cell.username.textColor = Constants.greenColor
            cell.message.font = UIFont.systemFont(ofSize: 13)
            cell.message.textColor = UIColor.gray
            cell.daysAgo.textAlignment = .right
            cell.profPic.contentMode = .scaleAspectFill
            cell.profPic.layer.cornerRadius = cell.profPic.frame.width/2
            cell.profPic.clipsToBounds = true
            
            //Set content of cell's objects
            
            let chatUserIds = chatObjects[(indexPath as NSIndexPath).row]["groupUsers"] as! Array<String>
            
            var chatUsernames = Array<String>()
            
            for id in chatUserIds {
                if id != PFUser.current()?.objectId {
                    chatUsernames.append(idToUser[id]!["username"] as! String)
                }
            }
            
            if chatUsernames.count == 1 {
                cell.username.text = chatUsernames.first
            } else {
                var usernameLabelContent = ""
                for username in chatUsernames {
                    usernameLabelContent += username
                    if chatUsernames.index(of: username) != chatUsernames.count - 1 {
                       usernameLabelContent += ", "
                    }
                }
                cell.username.text = usernameLabelContent
            }
            
            let pictureFile = idToUser[chatUserIds.first!]!["profilePicture"] as! PFFile
            MDBSwiftParseUtils.setImageViewImageFromFile(pictureFile, imageView: cell.profPic)
            
            let postTime:Date? = chatObjects[(indexPath as NSIndexPath).row].updatedAt!
            cell.daysAgo.text = MDBSwiftUtils.timeSince(postTime!)
            
            //Format differently if the most recent message in the chat hasn't been seen by the current user
            
            let lastMessageFrom = chatObjects[(indexPath as NSIndexPath).row]["lastMessageFrom"] as! String
            if lastMessageFrom != PFUser.current()?.objectId {
                let lastMessageSeen = chatObjects[(indexPath as NSIndexPath).row]["lastMessageSeen"] as! Bool
                if lastMessageSeen == false {
                    cell.daysAgo.textColor = UIColor.green
                    cell.daysAgo.font = UIFont.boldSystemFont(ofSize: 10)
                    cell.username.font = UIFont.boldSystemFont(ofSize: 14)
                    cell.message.font = UIFont.boldSystemFont(ofSize: 13)
                }
            }
            
            var messageText = ""
            
            if lastMessageFrom == PFUser.current()?.objectId {
                messageText += "You: "
            } else {
                if idToUser[lastMessageFrom] != nil {
                    messageText += idToUser[lastMessageFrom]!["username"] as! String + " "
                }
            }
            
            messageText += chatObjects[(indexPath as NSIndexPath).row]["lastMessage"] as! String
            
            cell.message.text = messageText
            
            
            return cell

        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatVC" {
            let navVC = segue.destination as! UINavigationController
            let chatVC = navVC.topViewController as! ChatViewController
            if self.chatObjects.count > 0 {
                let chatObjectArr = [chatObjects[currChatIndex]]
                chatVC.currChatObjects = chatObjectArr
                
            }
                        print("the groupid first is")
            print(selectedGroupId)
            chatVC.groupId = selectedGroupId
            
            print("username to pass is")
            print(usernameTextToPass)
            chatVC.usernameText = usernameTextToPass
            
            let allChatUsers = self.chatObjects[currChatIndex]["groupUsers"] as! Array<String>
            var otherChatUsers = Array<String>()
            
            for chatUser in allChatUsers {
                if chatUser != PFUser.current()?.objectId {
                    otherChatUsers.append(chatUser)
                }
            }
            
            if self.chatObjects.count > 0 {
                chatVC.otherUserIds = otherChatUsers
            } else {
                chatVC.otherUserIds = usersToAdd
            }
            
            
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == usersTableView {
            
            let cell = usersTableView.cellForRow(at: indexPath)
            let userId = allUsers[(indexPath as NSIndexPath).row].objectId!
            
            if usersToAdd.contains(userId) {
                cell?.accessoryType = .none
                for userToAdd in usersToAdd {
                    if userToAdd == userId {
                        usersToAdd.remove(at: usersToAdd.index(of: userToAdd)!)
                    }
                }
            } else {
                cell?.accessoryType = .checkmark
                usersToAdd.append(userId)
            }
            
            
        } else {
            
            let cell = tableView.cellForRow(at: indexPath) as! ChatsTableViewCell
            
            usernameTextToPass = cell.username.text!
            
            currChatIndex = (indexPath as NSIndexPath).row
            
            print("while setting it is")
            print(chatObjects[(indexPath as NSIndexPath).row].objectId!)
            selectedGroupId = chatObjects[(indexPath as NSIndexPath).row].objectId!
            self.performSegue(withIdentifier: "toChatVC", sender: self)
            
        }
        
    }
    
    func refresh() {
        chatObjects = Array<PFObject>()
        getChats()
        refresher.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }
    
    
    
    // Creates a UIColor from a Hex string.
    func colorWithHexString (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
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
    @IBAction func newChat(_ sender: AnyObject) {
        print("getting in this area")
        
        let popupTitleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width - 40, height: 40))
        let popupOkayButton = UIButton()
        popupTitleLabel.font = UIFont(name: "American Typewriter", size: 20)
        popupTitleLabel.textColor = Constants.lightGreenColor
        popupTitleLabel.textAlignment = .center
        popupTitleLabel.text = "CREATE NEW CHAT"
        var popupViewHeight = 10 + popupTitleLabel.frame.height + 5 + 100 + 10 + 40 + 10
        //        popupView.frame = CGRect(x: 10, y: 100, width: UIScreen.mainScreen().bounds.width - 20, height: popupViewHeight)
        popupOkayButton.frame = CGRect(x: 10, y: popupTitleLabel.frame.maxY + 315, width: popupView.frame.width - 20, height: 40)
        popupOkayButton.setTitle("CHAT!", for: UIControlState())
        popupOkayButton.setTitleColor(UIColor.white, for: UIControlState())
        popupOkayButton.titleLabel?.textColor = Constants.lightGreenColor
        popupOkayButton.titleLabel!.font = UIFont(name: "Gujarati Sangam MN", size: 20)
        popupOkayButton.backgroundColor = Constants.lightGreenColor
        popupOkayButton.layer.cornerRadius = 5
        popupOkayButton.addTarget(self, action: #selector(ChatsTableViewController.addPersonToChat), for: .touchUpInside)
        popupView.backgroundColor = UIColor.white
        popupView.addSubview(popupTitleLabel)
        popupView.addSubview(popupOkayButton)
        popupView.bringSubview(toFront: popupOkayButton)
        
        usersTableView.frame = CGRect(x: 0, y: popupTitleLabel.frame.maxY + 60, width: UIScreen.main.bounds.width - 20, height: 300)
        usersTableView.reloadData()
        popupView.addSubview(usersTableView)
        
//        
//        var groupNameTextField = UITextField(frame: CGRect(x: 10, y: popupTitleLabel.frame.maxY + 10, width: UIScreen.mainScreen().bounds.width - 40, height: 30))
//        groupNameTextField.font = UIFont(name: "Helvetica", size: 13)
//        groupNameTextField.placeholder = "Chat Name (optional)"
//        groupNameTextField.borderStyle = .None
//        groupNameTextField.layer.cornerRadius = 4
//        groupNameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
//        groupNameTextField.layer.borderWidth = 0.5
//        let paddingView = UIView(frame: CGRectMake(0, 0, 10, groupNameTextField.frame.height))
//        groupNameTextField.leftView = paddingView
//        groupNameTextField.leftViewMode = UITextFieldViewMode.Always
//        popupView.addSubview(groupNameTextField)
        
        
        searchBar.frame = CGRect(x: 10, y: popupTitleLabel.frame.maxY + 15, width: UIScreen.main.bounds.width - 40, height: 30)
        searchBar.delegate = self
        searchBar.placeholder = "Search Users"
        searchBar.barTintColor = UIColor.white
        searchBar.layer.cornerRadius = 3
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        popupView.addSubview(searchBar)
        
        
        
        
        
        popupView.bringSubview(toFront: usersTableView)
        popupView.bringSubview(toFront: popupOkayButton)
        
        
        
        
        
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        popupConfig.showCompletion = { popupView in
            
        }
        popupConfig.dismissCompletion = { popupView in
            popupTitleLabel.removeFromSuperview()
            popupOkayButton.removeFromSuperview()
            self.usersTableView.removeFromSuperview()
        }
        
        presentPopupView(popupView, config: popupConfig)
        
    }
    
    func addPersonToChat() {
        let chatObject = PFObject(className: "Chats")
        if usersToAdd.count > 1 {
            chatObject["isGroup"] = true
        }
        chatObject["lastMessage"] = ""
        var allChatUsers = usersToAdd
        allChatUsers.append((PFUser.current()?.objectId)!)
        chatObject["groupUsers"] = allChatUsers
        chatObject["lastMessageSeen"] = false
        chatObject["lastMessageFrom"] = PFUser.current()?.objectId
        chatObject["messageUids"] = Array<String>()
        chatObject["showChat"] = false
        chatObject.saveInBackground {
            (success, error) in
            if success == true {
                print("got the chat object")
                print(chatObject)
                self.chatObjectToPass = chatObject
                self.selectedGroupId = chatObject.objectId!
                print("now id is okay")
                print(chatObject.objectId)
                self.dismissPopupView()
                if self.usersToAdd.count != 0 {
                    self.usersToAdd = Array<String>()
                    self.performSegue(withIdentifier: "toChatVC", sender: self)
                }
                
            } else {
                //                    println(error)
            }
        }
        
        

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let timer = debounceTimer {
            timer.invalidate()
        }
        debounceTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(ChatsTableViewController.searchQuery), userInfo: nil, repeats: false)
        RunLoop.current.add(debounceTimer!, forMode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"))
    }
    
    func searchQuery() {
        searchBarText = searchBar.text!.lowercased()
        getUsers()
    }

    
    func getUsers() {
        let query = PFQuery(className:"_User")
        query.whereKey("status", notEqualTo: false)
        
        if searchBarText != "" {
            query.whereKey("username", matchesRegex: searchBarText, modifiers: "i")
        }

        
        print(PFUser.current())
        query.whereKey("objectId", notEqualTo: (PFUser.current()?.objectId)!)
        
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    self.allUsers = objects
                    self.usersTableView.reloadData()
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    func setupTableView() {
        
        usersTableView.delegate = self
        usersTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "userCell")
        usersTableView.dataSource = self
    }

}
