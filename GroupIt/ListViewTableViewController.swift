//
//  ListViewTableViewController.swift
//  ParseStarterProject
//
//  Created by Sona Jeswani on 11/19/15. --------
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import JGProgressHUD
import ParseFacebookUtilsV4


class ListViewTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //Vars to pass for chat segue
    var selectedGroupId = ""
    var selectedUsernameToPass = ""
    var selectedOtherUserIds = Array<String>()
    
    var newLocation: CLLocation?
    var userCount = 0;
    var ParseUserList = Array<PFObject>()
    var allUsers = Array<String>()
    var allProfPics = Array<PFFile>()
    var userObjects = Array<PFObject>()
    var lightColor = UIColor.gray
    var darkColor = UIColor.gray
    var toggleColor = UIColor.green
    
    var friendUsernames = Array<String>()
    var filteredStringObjects = Array<String>()
    
    var searchActive: Bool = false
    var data: [String] = []
    var filtered: [String] = []
    var nameToUserDict = Dictionary<String, PFObject>()
    var locationManager = CLLocationManager()
    var currUserGeoPoint = PFGeoPoint()
    var filteredObjects = Array<PFObject>()
    var chatObjectToPass:PFObject!
    var otherUser:PFObject!
    var locationArray = Array<PFGeoPoint>()
    var timer: Timer?
    var friendMode = false
    func getUsernames() {
        data = []
        
        for object in userObjects {
            data.append(object["username"] as! String);
        }
    }
    
    func timerTest() {
        print("Passed 5 seconds and the test.")
    }
    
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var friendsToggleSwitch: UISwitch!
    
    
    @IBAction func friendSwitchToggled(_ sender: AnyObject) {
        if self.friendsToggleSwitch.isOn == true {
            let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.light)
            HUD.textLabel.text = "Showing Facebook Friends"
            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            HUD.show(in: self.view!)
            HUD.dismiss(afterDelay: 1.5)
            friendMode = true
            getUsers()
            //refresh()
        } else {
            friendMode = false
            getUsers()
            //refresh()
        }
    }
   
    
    
    @IBAction func didSwitchChange(_ sender: AnyObject) {
        
//        if self.toggleSwitch.on {
//            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAndSaveLocation", userInfo: nil, repeats: true)
//            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
//            HUD.textLabel.text = "Online"
//            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
//            HUD.showInView(self.view!)
//            HUD.dismissAfterDelay(1.0)
//            
//        }
//        else {
//            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
//            HUD.textLabel.text = "Offline"
//            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
//            HUD.showInView(self.view!)
//            HUD.dismissAfterDelay(1.0)
//        }
//
//        
//        
//        var query = PFQuery(className:"_User")
//        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                // The find succeeded.
//                print("Successfully retrieved \(objects!.count) scores.")
//                // Do something with the found objects
//                if let objects = objects {
//                    for object in objects {
//                        if self.toggleSwitch.on {
//                        object["status"] = true
//                        }
//                        else
//                        {
//                            object["status"] = false
//                        }
//                        
//                        object.saveInBackgroundWithTarget(nil, selector: nil)
//
//                        
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
    }
    
    
    func getFriendsArray() {
      
                
        var fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);

        fbRequest?.start { (connection : FBSDKGraphRequestConnection?, result : Any?, error : Error?) -> Void in
            
            if error == nil {
                
                self.friendUsernames = []
                
                var resultDict = result as! NSDictionary
                
                var dataArr = resultDict.object(forKey: "data") as! NSArray
                print("the count is")
                print(dataArr.count)
                for i in 0 ..< dataArr.count {
                    var valueDict = dataArr[i] as! NSDictionary
                    var currUsername = valueDict.object(forKey: "name") as! String
                    self.friendUsernames.append(currUsername)
                    print(currUsername)
                }
                
                print("the usernames are")
                print(self.friendUsernames)
                //friendUsernames = self.friendUsernames
                
                self.tableView.reloadData()
                //self.getFriendUserObjects(friendUsernames)
                
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       // tableView.backgroundColor = UIColor.whiteColor()
       // self.view.backgroundColor = Constants.greenColor
        self.friendsToggleSwitch.isOn = false
        self.getLocationsArray() //gets all locations
        self.getFriendsArray()
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        toggleColor = colorWithHexString("#a5e4ff")
        
        
        friendsToggleSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.friendsToggleSwitch.onTintColor = colorWithHexString("#3b5998")
        self.friendsToggleSwitch.tintColor = UIColor.white
        
        //toggleSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
        let myGrayColor = colorWithHexString ("#9ddaf6")
        //self.toggleSwitch.onTintColor = toggleColor
        //self.toggleSwitch.tintColor = UIColor.whiteColor()
        //self.toggleSwitch.backgroundColor = UIColor.whiteColor()
       // self.toggleSwitch.sendSubviewToBack(toggleSwitch)
//        self.toggleSwitch.layer.borderWidth = 1
//        self.toggleSwitch.layer.borderColor = UIColor.whiteColor().CGColor
//        self.toggleSwitch.layer.cornerRadius = 16
        
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        let tapToDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ListViewTableViewController.dismissKeyboard))
        tapToDismiss.cancelsTouchesInView = false
        self.view!.addGestureRecognizer(tapToDismiss)
        
        
        
        
//        if PFUser.currentUser()!["status"] as! Bool == false {
//            toggleSwitch.on = false
//        }
        
        self.refreshControl?.addTarget(self, action: #selector(ListViewTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
    
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "blue_navbar-Recovered3.jpg"), for: UIBarMetrics.default)
        
        self.navigationController!.navigationBar.isHidden = false
        //        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 0.459, green: 0.102, blue: 1, alpha: 1)
//        self.navigationController!.navigationBar.barTintColor = UIColor.purpleColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        if CLLocationManager.locationServicesEna/.bled()  {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//            
//        }
        
        
        getAndSaveLocation()
        
//        if toggleSwitch.on {
//        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAndSaveLocation", userInfo: nil, repeats: true)
//       }
    
        
        let currLocation = locationManager.location
        currUserGeoPoint = PFGeoPoint(location: currLocation)
        if currUserGeoPoint == nil {
            currUserGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        }

        getUsers()
        
        self.tableView.keyboardDismissMode = .interactive
        
     
    }
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
            
            
            //Location permissions changed
            
    
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("got to dissappear")
        timer?.invalidate()
        timer = nil
    }
    
    func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]) {
        self.newLocation = locations.last
        print("current position: \(self.newLocation!.coordinate.longitude) , \(self.newLocation!.coordinate.latitude)")
        //        locationManager.stopUpdatingLocation()
        getAndSaveLocation()
        
    }
    
    func getAndSaveLocation() {
        
        locationManager.startUpdatingLocation()
        //locationManager.stopUpdatingLocation()
        print("getting the location")
        var currLocation = locationManager.location
        currUserGeoPoint = PFGeoPoint(location: currLocation)
        print(currUserGeoPoint.latitude)
        
        var query = PFQuery(className:"_User")
        NSLog("User: %@", (PFUser.current()?.objectId)!)
        query.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if self.currUserGeoPoint != nil {
                            
                            //object["location"] = self.currUserGeoPoint
                            //print("THE LOCATION IS", self.newLocation)
                            //object["location"] = PFGeoPoint(latitude: 123, longitude: 123)
                            
                            print("CURRENTTTT position: \(self.newLocation?.coordinate.longitude) , \(self.newLocation?.coordinate.latitude)")
                            
                            object["location"] = PFGeoPoint(location: self.newLocation)
                            print("saved loc", object["location"])
                            
                        } else {
                            object["location"] = PFGeoPoint(latitude: 1234, longitude: 5678)
                        }
                        let status = object["status"] as! Bool
//                        if status == false {
//                            self.toggleSwitch.on = false
//                        } else {
//                            self.toggleSwitch.on = true
//                        }
                        print("got hereee")
                        object.saveInBackground(withTarget: nil, selector: nil)
                        }
                    
                    
                }
            }
             else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
    }
    
    
    
    func getLocationsArray() {
        
        print("GeT LOCATIONS ARRAY NEXT AFTER THIS STATEMENT")
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//            print("getting the locations of all users")
//            var currLocation = locationManager.location
//            currUserGeoPoint = PFGeoPoint(location: currLocation)
//            print(currUserGeoPoint.latitude)
        
            var query = PFQuery(className:"_User")
            //query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
            query.findObjectsInBackground {
                (objects: [PFObject]?, error: Error?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    print("SO FAR ALL GOOD")
                    if let objects = objects {
                        for object in objects {
                            if object["location"] != nil {
                                self.locationArray.append(object["location"] as! PFGeoPoint)

                            }
                                                        //object["location"] = self.currUserGeoPoint
                            //print("got hereee")
                            //object.saveInBackgroundWithTarget(nil, selector: nil)
                        }
                        
                        
                    }
                }
                else {
                    // Log details of the failure
                    //print("Error: \(error!) \(error!.userInfo)")
                }
            }
        for elem in self.locationArray {
//            print(elem)
        }
        print("GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS")
    }

    
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func refresh() {
        userCount = 0;
        ParseUserList = Array<PFObject>()
        allUsers = Array<String>()
        allProfPics = Array<PFFile>()
        userObjects = Array<PFObject>()
        
        //friendUsernames = Array<String>()
        filteredStringObjects = Array<String>()
        
        data = []
        filtered = []
        nameToUserDict = Dictionary<String, PFObject>()
        filteredObjects = Array<PFObject>()
        locationArray = Array<PFGeoPoint>()
        getFriendsArray()
        print("REFRESHING FRIENDS AND HERE THEY ARE")
        getUsers()
        self.tableView.reloadData()
        refreshControl!.endRefreshing()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh()
//        self.getFriendsArray()
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        if searchText != "" {
//            for object in userObjects {
//                if (object["username"] as! String).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil || (object["activeClass"] as! String).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
//                    if filteredObjects.contains(object) == false {
//                        print("adding filtered obj")
//                        filteredObjects.append(object)
//                    }
//                }
//            }
//        } else {
//            filteredObjects = userObjects
//        }
//        
        print("filtered objects are")
        print(filteredObjects)
        
        if !(searchText == "") {
            filteredObjects = userObjects.filter({ (object) -> Bool in
                let activeClass: NSString = object["activeClass"] as! String as NSString
                let username: NSString = object["username"] as! String as NSString
                let rangeOne = activeClass.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                let rangeTwo = username.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                
                if rangeOne.location != NSNotFound || rangeTwo.location != NSNotFound {
                    return true
                } else {
                    return false
                }
                
            })
        } else {
            filteredObjects = userObjects
        }
        
        if(filteredObjects.count == 0){
            searchActive = true
            ; /*True if you want to display all results when the search text does not match any results, rather than displaying none */
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(searchActive) {
            return filteredObjects.count
        }
        return self.userObjects.count;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("got inside didselect")
       //tonewchat
        
        
        handleChatUser(userObjects[(indexPath as NSIndexPath).row].objectId!, username: userObjects[(indexPath as NSIndexPath).row]["username"] as! String)
        
        
        
    }
    
    func makeNewChat(_ userId: String, username: String) {
        let chatObject = PFObject(className: "Chats")
        chatObject["isGroup"] = false
        chatObject["lastMessage"] = ""
        var allChatUsers = Array<String>()
        allChatUsers.append((PFUser.current()?.objectId)!)
        allChatUsers.append(userId)
        chatObject["groupUsers"] = allChatUsers
        chatObject["lastMessageSeen"] = false
        chatObject["lastMessageFrom"] = PFUser.current()?.objectId
        chatObject["messageUids"] = Array<String>()
        chatObject["showChat"] = false
        chatObject.saveInBackground {
            (success, error) in
            if success == true {
                
                self.selectedGroupId = chatObject.objectId!
                
                var otherUserIds = Array<String>()
                otherUserIds.append(userId)
                self.selectedOtherUserIds = otherUserIds
                
                self.selectedUsernameToPass = username
                
                self.performSegue(withIdentifier: "toNewChat", sender: self)
            } else {
                //                    println(error)
            }
        }

    }
    
    func handleChatUser(_ userId: String, username: String) {
        //Check if chat between the users exists
        
        let query = PFQuery(className: "Chats")
        query.whereKey("groupUsers", containsAllObjectsIn: [(PFUser.current()?.objectId)!, userId])
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    var exists = false
                    var chatObject: PFObject?
                    for object in objects {
                        if object["groupUsers"] != nil {
                            let groupUsers = object["groupUsers"] as! Array<String>
                            if groupUsers.count == 2 {
                                //The chat between the users already exists
                                exists = true
                                chatObject = object
                            }
                        }
                    }
                    
                    if exists == true {
                        self.selectedGroupId = (chatObject?.objectId)!
                        self.selectedUsernameToPass = username
                        var otherUserIds = Array<String>()
                        otherUserIds.append(userId)
                        self.selectedOtherUserIds = otherUserIds
                        self.performSegue(withIdentifier: "toNewChat", sender: self)
                    } else {
                        self.makeNewChat(userId, username: username)
                    }
                    
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        
        cell.cellProfilePic.image = nil
        cell.backgroundColor = UIColor.white
//        cell.greenDotFriend.hidden = true
        
        for elem in filteredObjects {
            var userString = elem["username"] as! String
            self.filteredStringObjects.append(userString)
        }
//        
//        for elem in self.filteredStringObjects {
//            if filteredStringObjects.contains(elem) {
//                cell.greenDotFriend.hidden = false
//            } else {
//                cell.greenDotFriend.hidden = true
//            }
//        }
//        
        
        
        if(searchActive){
            if filteredObjects.count > (indexPath as NSIndexPath).row {
                cell.cellNameLabel.text = filteredObjects[(indexPath as NSIndexPath).row]["username"] as! String
                cell.cellNameLabel.textColor = UIColor.gray
                (filteredObjects[(indexPath as NSIndexPath).row]["profilePicture"] as! PFFile).getDataInBackground({
                    (imageData: Data?, error: Error?) -> Void in
                    if error == nil {
                        
                        cell.cellProfilePic.image = nil
                        
                        cell.cellProfilePic.image = UIImage(data:imageData!)
                        cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
                        cell.cellProfilePic.clipsToBounds = true
                        
                        
                        
                        
                    } else {
                        print(error)
                    }
                })
                
                
//                var cellUserGeoPoint = filteredObjects[indexPath.row]["location"] as! PFGeoPoint
//                var distance = currUserGeoPoint.distanceInMilesTo(cellUserGeoPoint)
//                cell.cellDistance.font = UIFont.systemFontOfSize(15)
//                cell.cellDistance.textColor = Constants.greenColor
//                if distance < 1 {
//                    cell.cellDistance.text = String(format: "%.0f", (distance*5280)) + " ft"
//                } else {
//                    cell.cellDistance.text = String(format: "%.0f", (distance)) + " mi"
//                }
                
                
                var theActiveClass = filteredObjects[(indexPath as NSIndexPath).row] as! String
                
                
                cell.cellActiveClass.textColor = Constants.greenColor
                
                if theActiveClass.characters.count <= 2 {
                    cell.cellActiveClass.font = UIFont.systemFont(ofSize: 12)
                    cell.cellActiveClass.text = "None"
                    cell.cellActiveClass.textColor = Constants.greenColor
                    
                    //tableView.deleteRowsAtIndexPaths(NSArray(object: NSIndexPath(forRow: indexPath.row, inSection: 2)) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                else {
                    
                    cell.cellActiveClass.text = filteredObjects[(indexPath as NSIndexPath).row]["activeClass"] as! String
                    cell.cellActiveClass.font = UIFont.systemFont(ofSize: 20)
                    cell.cellActiveClass.textColor = Constants.greenColor
                }


            }
            
            } else {   //if we're not searching
            cell.cellActiveClass.textColor = Constants.greenColor
            cell.cellNameLabel.text = userObjects[(indexPath as NSIndexPath).row]["username"] as! String
            cell.cellNameLabel.textColor = UIColor.gray
            (userObjects[(indexPath as NSIndexPath).row]["profilePicture"] as! PFFile).getDataInBackground({
                (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    
                    cell.cellProfilePic.image = nil
                    
                    cell.cellProfilePic.image = UIImage(data:imageData!)
                    cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
                    cell.cellProfilePic.clipsToBounds = true
                } else {
                    print(error)

                }
            })
            
            var cellUserGeoPoint = userObjects[(indexPath as NSIndexPath).row]["location"] as! PFGeoPoint
            var distance = currUserGeoPoint.distanceInMiles(to: cellUserGeoPoint)
            cell.cellDistance.font = UIFont.systemFont(ofSize: 15)
            cell.cellDistance.textColor = Constants.greenColor
            if distance < 1 {
                cell.cellDistance.text = String(format: "%.0f", (distance*5280)) + " ft"
            } else {
                cell.cellDistance.text = String(format: "%.0f", (distance)) + " mi"
            }
            
            var theActiveClass = userObjects[(indexPath as NSIndexPath).row]["activeClass"] as! String
            
            if theActiveClass.characters.count <= 2 {
                cell.cellActiveClass.font = UIFont.systemFont(ofSize: 20)
                cell.cellActiveClass.text = "None"
                
                //tableView.deleteRowsAtIndexPaths(NSArray(object: NSIndexPath(forRow: indexPath.row, inSection: 2)) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else {
                
                cell.cellActiveClass.text = userObjects[(indexPath as NSIndexPath).row]["activeClass"] as! String
                cell.cellActiveClass.font = UIFont.systemFont(ofSize: 20)
            }

        }
        
        var found = false
//        cell.greenDotFriend.hidden = true
        for friend in self.friendUsernames {
            if friend == cell.cellNameLabel.text {
                print("got inside here")
                found = true
            }
        }
        
        if found == false {
            cell.greenDotFriend.isHidden = true
        } else {
            cell.greenDotFriend.isHidden = false
        }
        	
        
        //ALL GOOD AFTER HERE
//        userObjects[indexPath.row]["profilePicture"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
//            if error == nil {
//                
//                cell.cellProfilePic.image = nil
//                
//                cell.cellProfilePic.image = UIImage(data:imageData!)
//                cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
//                cell.cellProfilePic.clipsToBounds = true
//            } else {
//                print(error)
//            }
//        }
        
        
        return cell
    }
    
  
    var notIncluded:[String] = ["", "<your class here>"]

    
    func getUsers() {
        userObjects = Array<PFObject>()
        nameToUserDict = Dictionary<String, PFObject>()
        let query = PFQuery(className:"_User")
        query.whereKey("status", notEqualTo: false)
        
        print(PFUser.current())
        query.whereKey("objectId", notEqualTo: (PFUser.current()?.objectId)!)
        
        //query.whereKey("activeClass", notEqualTo: "")
        //query.whereKey("activeClass", notEqualTo: "<your class here>")
        
        query.whereKey("activeClass", notContainedIn: notIncluded)
        
        query.whereKey("location", nearGeoPoint: currUserGeoPoint, withinMiles: 100)
        if friendMode == true {
            query.whereKey("username", containedIn: self.friendUsernames)
        }
        
        
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    self.userObjects = objects
                    for userObject in self.userObjects {
                        self.nameToUserDict[userObject["username"] as! String] = userObject
                    }
                    //self.membersTableView.reloadData()
                    self.getUsernames()
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewChat" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! ChatViewController
            destVC.groupId = self.selectedGroupId
            destVC.otherUserIds = self.selectedOtherUserIds
            destVC.usernameText = self.selectedUsernameToPass
        }
    }
    
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
    

    

//
//    func getProfPics() {
//        let query = PFQuery(className:"_User")
//        do {
//            let objects = try query.findObjects()
//            for object in objects {
//                allProfPics.append(object["profilePicture"] as! PFFile)
//            }
//        } catch {
//            print("error")
//        }
//        self.tableView.reloadData()
//    }
    

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
//    func getLocation() {
//        PFGeoPoint.geoPointForCurrentLocationInBackground {
//            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
//            if error == nil {
////                if let objects = objects as [PFObject]! {
////                    for object in objects {
////                        object["user_courses"] = updatedClasses
////                        object.saveInBackgroundWithTarget(nil, selector: nil)
//                let location = geoPoint
//                // User's location
//               
//                // Create a query for places
//                var query = PFQuery(className:"PlaceObject")
//                //Interested in locations near user.
//                query.whereKey("location", nearGeoPoint:userGeoPoint)
//                
//                let userGeoPoint = PFUser.currentUser()?.location
//                object["location"] = userGeopoint
//                object.saveInBackgroundWithTarget(nil, selector: nil)
//
//                query.limit = 10
//                // Final list of objects
//                placesObjects = query.findObjects()
//                
//                // save location to Parse
//                
//                PFUser.currentUser()!.setValue(geoPoint, forKey: "location")
//                PFUser.currentUser()?.saveInBackground()
//            }
//        }
//    }
    
    

    }

