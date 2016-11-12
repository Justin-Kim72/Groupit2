//
//  ViewableProfileTableViewController.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/6/16.
//  Copyright © 2016 Sona and Ally. All rights reserved.
//

import UIKit
import Parse

class ViewableProfileTableViewController: UITableViewController {

    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var classOne: UILabel!
    
    @IBOutlet weak var classTwo: UILabel!
    
    @IBOutlet weak var classThree: UILabel!
    
    @IBOutlet weak var classFour: UILabel!
    
    @IBOutlet weak var username: UILabel!
    
    var currUserObject: PFObject!
    
    var otherUserId = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupNavBar()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
        
        profilePic.contentMode = .scaleAspectFill
        profilePic.layer.borderColor = Constants.greenColor.cgColor
        profilePic.layer.borderWidth = 2
        profilePic.clipsToBounds = true
        profilePic.layer.cornerRadius = profilePic.bounds.width + 5
        
        getCurrUserObject()
    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.tintColor = Constants.appBlueCOlor
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        if section == 0 {
            return 1
        }
        else {
            return 4
        }

       
    }
    
    
        
    func getCurrUserObject() {
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: otherUserId)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) classes.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        
                        self.currUserObject = objects.first
                        
                        MDBSwiftParseUtils.setImageViewImageFromFile(self.currUserObject["profilePicture"] as! PFFile, imageView: self.profilePic)
                        
                        self.username.text = self.currUserObject["username"] as? String
                        
                        if self.currUserObject["user_courses"] != nil {
                            
                            
                            let classArray = self.currUserObject["user_courses"] as! Array<String>
                            
                            if classArray.count > 0 {
                                self.classOne.text = classArray[0]
                            }
                            if classArray.count > 1 {
                                self.classTwo.text = classArray[1]
                            }
                            if classArray.count > 2 {
                                self.classThree.text = classArray[2]
                            }
                            if classArray.count > 3 {
                                self.classFour.text = classArray[3]
                            }
                            

                        }

                        self.tableView.reloadData()
                    }
                }
               
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 175
        }
        else {
            return 45
        }
        
    }

}

