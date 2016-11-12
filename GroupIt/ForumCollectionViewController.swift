//
//  ForumCollectionViewController.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/21/16.
//  Copyright © 2016 Sona and Ally. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"



class ForumCollectionViewController: UICollectionViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    var postObjects = Array<PFObject>()
    var searchBarBoundsY:CGFloat?
    var refreshControl:UIRefreshControl!
    var idToUser = Dictionary<String, PFObject>()
    
    
    //For use with search functionality
    var searchBar:UISearchBar?
    var debounceTimer: Timer?
    var searchWord = ""

    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupRefresher()
        setupNavBar()
        addSearchBar()
        getPosts()
    }
    
    func setupRefresher() {
        refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ForumCollectionViewController.handleRefresh(_:)), for: UIControlEvents .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        collectionView!.addSubview(refreshControl)
    }
    
    func setupCollectionView() {
        collectionView?.register(ForumCollectionViewCell.self, forCellWithReuseIdentifier: "forumCellNew")
        collectionView?.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1)
    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.barTintColor = Constants.appBlueCOlor
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Helvetica", size: 20)!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.title = "Forum"
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh()
        
    }
    
    func refresh() {
        self.postObjects = Array<PFObject>()
        getPosts()
        refreshControl!.endRefreshing()
    }
    
    func addSearchBar(){
        if self.searchBar == nil{
            self.searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
            
            self.searchBar = UISearchBar(frame: CGRect(x: 0,y: self.searchBarBoundsY!, width: UIScreen.main.bounds.size.width, height: 44))
            self.searchBar!.searchBarStyle       = UISearchBarStyle.minimal
            self.searchBar!.tintColor            = UIColor.white
            self.searchBar!.barTintColor         = UIColor.white
            self.searchBar!.delegate             = self
            self.searchBar!.placeholder          = "Search by class"
            
        }
        
        if !self.searchBar!.isDescendant(of: self.view){
            self.view.addSubview(self.searchBar!)
        }
    }
    
    // MARK: <UICollectionViewDelegateFlowLayout>
    func collectionView( _ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                                insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        return UIEdgeInsetsMake(self.searchBar!.frame.size.height, 0, 0, 0);
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let timer = debounceTimer {
            timer.invalidate()
        }
        debounceTimer = Timer(timeInterval: 0.6, target: self, selector: #selector(ForumCollectionViewController.searchQuery), userInfo: nil, repeats: false)
        RunLoop.current.add(debounceTimer!, forMode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"))
    }
    
    
    func searchQuery() {
        searchWord = searchBar!.text!.lowercased()
        refresh()
    }
    
    
    func trimString(_ toTrim: String) -> String {
        var substring = ""
        if (toTrim.characters.count > 100) {
            let index1 = toTrim.characters.index(toTrim.endIndex, offsetBy: 100 - toTrim.characters.count)
            substring = toTrim.substring(to: index1) + "..."
        } else {
            substring = toTrim
        }
        return substring
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var size = CGFloat()
        let labelWidth = UIScreen.main.bounds.width - 90
        print(postObjects.count)
        if postObjects.count == 0 {
            return CGSize(width: 350, height: 110)
        }
        let labelHeight = MDBSwiftUtils.getMultiLineLabelHeight(postObjects[(indexPath as NSIndexPath).row]["message"] as! String, maxWidth: Int(labelWidth), font: UIFont.systemFont(ofSize: 14))
        
        size = 100 + labelHeight - 46 + 20
    
        return CGSize(width: UIScreen.main.bounds.width - 20, height: size)
            //return CGSizeMake(350, 110)
       
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //var cell: UICollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forumCellNew", for: indexPath) as! ForumCollectionViewCell
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        
        cell.awakeFromNib()
        
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        //cell.layer.shadowColor = UIColor.blueColor().CGColor
        cell.layer.shadowColor = Constants.lightGreenColor.cgColor
        cell.layer.shadowRadius = 1.5
        cell.layer.cornerRadius = 3
        
        cell.layer.shadowOpacity = 0.35
        
        let shadowFrame: CGRect = (cell.layer.bounds)
        let shadowPath: CGPath = UIBezierPath(rect: shadowFrame).cgPath
        cell.layer.shadowPath = shadowPath

        
        if postObjects.count != 0 {
           print("RESIZINGGGGG")
            MDBSwiftUtils.formatMultiLineLabel(cell.postBodyText)
        let labelWidth = UIScreen.main.bounds.width - 90
        let labelHeight = MDBSwiftUtils.getMultiLineLabelHeight(postObjects[(indexPath as NSIndexPath).row]["message"] as! String, maxWidth: Int(labelWidth), font: UIFont.systemFont(ofSize: 14))
        cell.postBodyText.frame = CGRect(x: 60, y: 60, width: labelWidth, height: labelHeight)
        }
//        if (indexPath.row == 0) {
//            let thecell = collectionView.dequeueReusableCellWithReuseIdentifier("searchBar", forIndexPath: indexPath) as! SearchBarCollectionViewCell
//            
//            
//            return thecell
        
        //} else {
            //cell = collectionView.dequeueReusableCellWithReuseIdentifier("forumCell", forIndexPath: indexPath) as! ForumCollectionViewCell
            
            //let query = PFQuery(className:"_User")
           
            
            //for post in postObjects {
                       if postObjects.count > (indexPath as NSIndexPath).row {
                var message = postObjects[(indexPath as NSIndexPath).row]["message"] as! String
                //message = trimString(message)
                cell.postBodyText.text = message
                print("message is ", postObjects[(indexPath as NSIndexPath).row]["message"])
               
//                cell.postMainText.font = UIFont(name: "HelveticaNeue-Bold", size: 17.0)
                cell.postMainText.text = postObjects[(indexPath as NSIndexPath).row]["classTitle"] as! String
                //cell.timePosted.text = postObjects[indexPath.row]["createdAt"]
                //var userID = post["poster"] as! String
                print("user id is ", postObjects[(indexPath as NSIndexPath).row]["poster"])
                
                
                let userId = postObjects[(indexPath as NSIndexPath).row]["poster"] as! String
                
                if idToUser[userId] != nil {
                    let userObject = idToUser[userId]
                    
                    cell.profPic.image = nil
                    cell.profPic.layer.cornerRadius = cell.profPic.frame.size.width/2
                    cell.profPic.clipsToBounds = true
                    
                    MDBSwiftParseUtils.setImageViewImageFromFile(userObject!["profilePicture"] as! PFFile, imageView: cell.profPic)
                    
                    cell.username.text = userObject!["username"] as! String
                    
                }
             
                
                
                cell.timePosted.text = MDBSwiftUtils.timeSince(postObjects[(indexPath as NSIndexPath).row].createdAt!)


            //}
        }
        
    
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let destVC = segue.destination as! CommentsTableViewController
            destVC.postInfo = postObjects[index]
            
            if idToUser[postObjects[index]["poster"] as! String] != nil {
                destVC.posterObject = idToUser[postObjects[index]["poster"] as! String]
            }
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Commented out so comment functionality doesn't show
        
//        if searchBarActive == true {
//            self.index = filteredObjects[indexPath.row]
//        } else {
//            self.index = postObjects[indexPath.row]
//        }
//        self.index = indexPath.row
//        self.performSegueWithIdentifier("toComments", sender: self)
    }
    
    func getUsers(_ userIds: Array<String>) {
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", containedIn: userIds)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    
                    for object in objects {
                        print("right point")
                        self.idToUser[object.objectId!] = object
                    }
                    
                    
                    self.collectionView!.reloadData()
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    
    func getPosts() {
        postObjects = Array<PFObject>()
        
        var query = PFQuery(className:"Forum")
        
        
        //Implements search
        if searchWord != "" {
            let titleQuery = PFQuery(className: "Forum")
            titleQuery.whereKey("classTitle", matchesRegex: searchWord, modifiers: "i")
            let messageQuery = PFQuery(className: "Forum")
            messageQuery.whereKey("message", matchesRegex: searchWord, modifiers: "i")
            query = PFQuery.orQuery(withSubqueries: [titleQuery, messageQuery])
        }
        
        print(PFUser.current())
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    self.postObjects = objects
                    
                    var userIds = Array<String>()
                    
                    for post in self.postObjects {
                        userIds.append(post["poster"] as! String)
                    }
                    
                    self.getUsers(userIds)
                    
                    
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

 
}
