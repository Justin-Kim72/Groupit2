//
//  MyProfileViewController.swift
//  ParseStarterProject
//
//  Created by Akkshay Khoslaa on 1/11/16. --
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import JGProgressHUD
import ParseFacebookUtilsV4
import STZPopupView
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class MyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 260))
    var blackImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 210))
    var secondBlackImageView = UIImageView(frame: CGRect(x: 0, y: 210, width: UIScreen.main.bounds.width, height: 50))
    var profPicImageView = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width - 130)/2, y: 35, width: 130, height: 130))
    var usernameLabel = UILabel(frame: CGRect(x: 10, y: 170, width: UIScreen.main.bounds.width - 20, height: 30))
    //    var logoutLabel = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 66, y: 222.5, width: 60, height: 25))
    var plusButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 90, y: 20, width: 80, height: 30))
    var saveButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 180)/2, y: UIScreen.main.bounds.height - 50, width: 180, height: 40))
    var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.light)
    var editButton = UIButton(frame: CGRect(x: 6, y: 222.5, width: 50, height: 25))
    var doneButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 30, y: 205, width: 20, height: 25))
    var activeClassLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width - 220)/2, y: 220, width: 220, height: 30))
    let popupView = UIView(frame: CGRect(x: 0, y: 200, width: Int(UIScreen.main.bounds.width), height: Int(3*(((UIScreen.main.bounds.width/320) * 80) + 50))))
    var showAlert = false
    var currUserObject: PFObject!
    var classes = Array<String>()
    var cells = Array<UITableViewCell>()
    var editButtons = Array<UIButton>()
    var doneButtons = Array<UIButton>()
    var classTextFields = Array<UITextField>()
    var classLabels = Array<UILabel>()
    var activeClassLabels = Array<UILabel>()
    var loaded = false
    var editMode = false
    var activeField:UITextField?
    var lightColor = UIColor.gray
    var darkColor = UIColor.gray
    var currActiveClass = String("nil")
    
    override func viewDidAppear(_ animated: Bool) {
        //        if showAlert == true {
        //            showContentAlert()
        //        }
    }
    func buttonAction(_ sender:UIButton!)
    {
        print("Button tapped")
        //        let loginManager = FBSDKLoginManager()
        //        loginManager.logOut()
        
        PFUser.logOutInBackground { (error:Error?) -> Void in
            
            if(error == nil) {
                
                self.dismiss(animated: true, completion: nil)
            } else {
                
            }
        }
        
        
        //self.window.rootViewController = ViewController(nibName: nil, bundle: nil)
        //self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
    //
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "logoutSeg" {
    //            let destVC = segue.destinationViewController as! ViewController
    //            destVC.performedLogout = true
    //        }
    //    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        for family: String in UIFont.familyNames()
        //        {
        //            print("\(family)")
        //            for names: String in UIFont.fontNamesForFamilyName(family)
        //            {
        //                print("== \(names)")
        //            }
        //        }
        
        activeClassLabel.frame = CGRect(x: editButton.frame.maxX + 10, y: 220, width: 220, height: 30)
        
        var tabBarHeight = UITabBar().frame.height
        saveButton.frame = CGRect(x: (UIScreen.main.bounds.width - 180)/2, y: UIScreen.main.bounds.height - 40 - 50 - 10, width: 180, height: 40)
        
        
        //        var image: UIImage = UIImage(named: "sathe")!
        //        self.tableView.backgroundView = nil
        //        self.tableView.backgroundColor = UIColor(patternImage: image)
        
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        
        let myPurpleColor = colorWithHexString ("#7d0541")
        let myGrayColor = colorWithHexString ("#9ddaf6")
        
        //        editButton.setImage(UIImage(named: "edit-1"), forState: .Normal)
        editButton.setTitle("Edit", for: UIControlState())
        editButton.layer.cornerRadius = 5
        editButton.layer.borderColor = UIColor.white.cgColor
        editButton.layer.borderWidth = 1
        editButton.addTarget(self, action: #selector(MyProfileViewController.editButtonPressed(_:)), for: .touchUpInside)
        editButton.tag = 3
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        //        editButton.setTitle("Test Button", forState: UIControlState.Normal)
        //        self.view.addSubview(editButton)
        
        activeClassLabel.text = "ACTIVE CLASS: "
        activeClassLabel.font = UIFont.systemFont(ofSize: 14)
        activeClassLabel.textAlignment = .center
        activeClassLabel.textColor = UIColor.white
        //        activeClassLabel.adjustsFontSizeToFitWidth = true
        
        
        saveButton.setTitle("SAVE", for: UIControlState())
        saveButton.setTitleColor(UIColor.white, for: UIControlState())
        saveButton.backgroundColor = Constants.greenColor
        saveButton.addTarget(self, action: #selector(MyProfileViewController.saveClasses), for: .touchUpInside)
        saveButton.layer.cornerRadius = 5
        saveButton.alpha = 0
        self.view.addSubview(saveButton)
        
        
        
        
        self.navigationController?.navigationBar.isHidden = true
        //beganKeyboardNotifications()
        //
        //        var tapToDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //        tapToDismiss.cancelsTouchesInView = false
        //        self.view!.addGestureRecognizer(tapToDismiss)
        
        
        getCurrUserObject()
        //        saveButton.setTitle("SAVE", forState: .Normal)
        //        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        //        saveButton.backgroundColor = myGrayColor
        //        saveButton.addTarget(self, action: "saveClasses", forControlEvents: .TouchUpInside)
        //        saveButton.layer.cornerRadius = 5
        //        saveButton.alpha = 0
        plusButton.setTitle(" ADD CLASS ", for: UIControlState())
        plusButton.setTitleColor(myGrayColor, for: UIControlState())
        plusButton.titleLabel?.adjustsFontSizeToFitWidth = true
        plusButton.titleLabel!.font = UIFont(name: "System", size: 9)
        plusButton.layer.cornerRadius = 4
        //plusButton.layer.borderColor = UIColor.grayColor().CGColor
        //plusButton.layer.borderWidth = 0.2
        plusButton.isHidden = true
        plusButton.alpha = 0
        plusButton.addTarget(self, action: #selector(MyProfileViewController.plusButtonPressed(_:)), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "profileCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.keyboardDismissMode = .interactive
        //tableView.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //endKeyboardNotifications()
    }
    func getCurrUserObject() {
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.currUserObject = objects.first
                        if self.currUserObject["user_courses"] != nil {
                            self.classes = self.currUserObject["user_courses"] as! Array<String>
                            print("curr classes are")
                            print(self.classes)
                        }
                        
                        if self.currUserObject["activeClass"] != nil {
                            self.activeClassLabel.text = "ACTIVE CLASS:" + (object["activeClass"] as! String)
                            self.currActiveClass = object["activeClass"] as! String
                        }
                        
                        self.loaded = true
                        for label in self.classLabels {
                            label.removeFromSuperview()
                        }
                        
                        for textField in self.classTextFields {
                            textField.removeFromSuperview()
                        }
                        self.cells = Array<UITableViewCell>()
                        self.editButtons = Array<UIButton>()
                        self.doneButtons = Array<UIButton>()
                        self.classTextFields = Array<UITextField>()
                        self.classLabels = Array<UILabel>()
                        self.activeClassLabels = Array<UILabel>()
                        self.tableView.reloadData()
                    }
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("classes are")
        print(classes)
        let numSmallRows = (UIScreen.main.bounds.height - 230)/50
        return Int(numSmallRows) + 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") 
        var numSmallRows = (UIScreen.main.bounds.height - 230)/50
        //cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle = .none
        print("right now the edit mode is (inside cellfor)")
        print(editMode)
        
        if (indexPath as NSIndexPath).row == 0 {
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            if loaded == true {
                var profPicFile = currUserObject["profilePicture"] as! PFFile
                profPicFile.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                    if error == nil {
                        var image1 = UIImage(data:imageData!)
                        self.profPicImageView.image = image1
                    } else {
                        print(error)
                    }
                }
            }
            var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
            effectView.frame = CGRect(x: 0, y: 210, width: UIScreen.main.bounds.width, height: 260)
            backgroundImageView.clipsToBounds = true
            //            backgroundImageView.addSubview(effectView)
            var yourFont: UIFont = UIFont.systemFont(ofSize: 23)
            usernameLabel.font = yourFont
            //            logoutLabel.setTitle("Logout", forState: .Normal)
            //            logoutLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            //            logoutLabel.titleLabel!.font = UIFont.systemFontOfSize(15)
            //
            //            //logoutLabel.textFfont = yourFont
            //            logoutLabel.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            //
            //
            profPicImageView.contentMode = .scaleAspectFill
            profPicImageView.layer.borderColor = Constants.greenColor.cgColor
            profPicImageView.layer.borderWidth = 2
            profPicImageView.clipsToBounds = true
            profPicImageView.layer.cornerRadius = profPicImageView.bounds.width/2
            backgroundImageView.image = UIImage(named: "campanile")
            blackImageView.image = UIImage(named: "black")
            blackImageView.alpha = 0.4
            secondBlackImageView.image = UIImage(named: "black")
            secondBlackImageView.alpha = 0.4
            backgroundImageView.clipsToBounds = true
            usernameLabel.text = PFUser.current()?.username
            // logoutLabel.text = "Logout"
            //logoutLabel.font = UIFont(name: "System", size: 10)
            //            logoutLabel.layer.borderWidth = 1
            //            logoutLabel.layer.borderColor = UIColor.whiteColor().CGColor
            //            logoutLabel.layer.cornerRadius = 3
            //usernameLabel.font = UIFont(name: "System", size: 18)
            usernameLabel.textColor = UIColor.white
            usernameLabel.textAlignment = .center
            //logoutLabel.titleColorForState(.Normal) = UIColor.whiteColor()
            //logoutLabel = Constants.greenColor
            //            logoutLabel.layer.borderColor = Constants.greenColor.CGColor
            //logoutLabel.textAlignment = .Center
            cell!.addSubview(backgroundImageView)
            cell?.addSubview(secondBlackImageView)
            cell!.addSubview(blackImageView)
            cell!.addSubview(profPicImageView)
            cell!.addSubview(usernameLabel)
            //            cell!.addSubview(logoutLabel)
            cell?.addSubview(activeClassLabel)
            cell!.bringSubview(toFront: profPicImageView)
            cell!.bringSubview(toFront: usernameLabel)
            //            cell!.bringSubviewToFront(logoutLabel)
            cell?.bringSubview(toFront: activeClassLabel)
            
            
            //            editButton.setImage(UIImage(named: "edit-1"), forState: .Normal)
            //            editButton.addTarget(self, action: "editButtonPressed:", forControlEvents: .TouchUpInside)
            //editButton.tag = indexPath.row - 1
            
            doneButton.setImage(UIImage(named: "checkmark"), for: UIControlState())
            doneButton.addTarget(self, action: #selector(MyProfileViewController.doneButtonPressed(_:)), for: .touchUpInside)
            doneButton.tag = (indexPath as NSIndexPath).row - 1
            doneButton.isHidden = true
            doneButton.alpha = 0
            
            cell?.addSubview(doneButton)
            cell?.addSubview(editButton)
            
        } else if (indexPath as NSIndexPath).row <= classes.count  {
            
            //            if cells.count < indexPath.row {
            print("right now the edit mode is")
            print(editMode)
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            
            
            var classTextField = UITextField(frame: CGRect(x: 20, y: ((cell?.frame.height)! - 45)/2 , width: UIScreen.main.bounds.width - 40, height: 45))
            classTextField.font = UIFont(name: (classTextField.font?.fontName)!, size: 17)
            classTextField.layer.cornerRadius = 1
            classTextField.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
            classTextField.borderStyle = .none
            
            classTextField.text = classes[(indexPath as NSIndexPath).row - 1]
            classTextField.placeholder = "<Your class here>"
            classTextField.textAlignment = .center
            classTextField.delegate = self
            classTextField.textColor = Constants.greenColor
            
            var classLabel = UILabel(frame: CGRect(x: 40, y: ((cell?.frame.height)! - 45)/2 , width: UIScreen.main.bounds.width - 80, height: 45))
            classLabel.textAlignment = .center
            classLabel.text = classes[(indexPath as NSIndexPath).row - 1]
            classLabel.font = classLabel.font.withSize(17)
            classLabel.textColor = Constants.greenColor
            
            
            
            let myBlueColor = colorWithHexString ("#9ddaf6")
            
            //activeClassLabel.textColor = Constants.greenColor
            //                activeClassLabel.adjustsFontSizeToFitWidth = true
            //                if (currUserObject["activeClass"] as! String) != classLabel.text {
            //                    activeClassLabel.alpha = 0
            //                    activeClassLabel.hidden = true
            //                }
            
            if editMode == true {
                classTextField.isHidden = false
                classTextField.alpha = 1
                classLabel.isHidden = true
                classLabel.alpha = 0
                print("got into edit place")
            } else {
                classTextField.isHidden = true
                classTextField.alpha = 0
                classLabel.isHidden = false
                classLabel.alpha = 1
            }
            
            //                activeClassLabels.append(activeClassLabel)
            classLabels.append(classLabel)
            classTextFields.append(classTextField)
            //                editButtons.append(editButton)
            //                doneButtons.append(doneButton)
            //                cell?.addSubview(activeClassLabel)
            //                cell?.addSubview(doneButton)
            cell?.addSubview(classLabel)
            //                                cell?.addSubview(editButton)
            cell?.addSubview(classTextField)
            cells.append(cell!)
            //            }
            
            
        } else if (indexPath as NSIndexPath).row == classes.count + 1 && (indexPath as NSIndexPath).row < 5 {
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            cell?.addSubview(plusButton)
            
            
        } else if (indexPath as NSIndexPath).row == Int(numSmallRows) {
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            //            cell?.addSubview(saveButton) **************
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if (indexPath as NSIndexPath).row == 0 {
            return 260
        } else {
            return (self.tableView.frame.size.height - 260)/5
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row != 0 && cells.count >= (indexPath as NSIndexPath).row && classTextFields[(indexPath as NSIndexPath).row - 1].text?.characters.count >= 2 {
            
            if editMode == false {
                currActiveClass = classLabels[(indexPath as NSIndexPath).row - 1].text!
            }
            activeClassLabel.text = "ACTIVE CLASS: " + currActiveClass!
            activeClassQuery(classes[(indexPath as NSIndexPath).row - 1])
            
            //            var newActiveClass = ""
            //            if editMode == true {
            //                newActiveClass = classTextFields[indexPath.row - 1].text!
            //            } else {
            //                newActiveClass = classLabels[indexPath.row - 1].text!
            //            }
            //
            //            activeClassLabel.text = "ACTIVE CLASS: " + newActiveClass
            //            activeClassQuery(newActiveClass)
            
            //            if currActiveClassLabel.hidden == true {
            //                for activeClassLabel in activeClassLabels {
            //                    activeClassLabel.hidden = true
            //                    activeClassLabel.alpha = 0
            //                }
            //                currActiveClassLabel.hidden = false
            //                UIView.animateWithDuration(0.25, animations: {
            //                    currActiveClassLabel.alpha = 1
            //                })
            //
            //                activeClassQuery(classes[indexPath.row - 1])
            //
            //            } else {
            //                currActiveClassLabel.hidden = true
            //                UIView.animateWithDuration(0.25, animations: {
            //                    currActiveClassLabel.alpha = 0
            //                })
            //            }
            //tableView.reloadData()
        }
        //tableView.reloadData()
    }
    
    //    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //        if indexPath.row != 0 && classTextFields.count >= indexPath.row - 1 {
    //            var updatedClasses = Array<String>()
    //            var currActiveClass = ""
    //            for (var i = 0; i < classLabels.count; i++) {
    //                if classLabels[i].alpha != 0 {
    //                    updatedClasses.append(classLabels[i].text!)
    //
    //                }
    //                if classTextFields[i].alpha != 0 {
    //
    //                    updatedClasses.append(classTextFields[i].text!)
    //
    //                }
    //            }
    //            print("the length is ")
    //            print(updatedClasses)
    //            updatedClasses.removeAtIndex(indexPath.row - 1)
    //
    //            if currActiveClass == "" {
    //                currActiveClass = (classLabels.first?.text)!
    //            }
    //            var currClass = classes[indexPath.row - 1]
    //            classes.removeAtIndex(indexPath.row - 1)
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
    //                        object["user_courses"] = updatedClasses
    //                        object["activeClass"] = currActiveClass
    //                        object.saveInBackgroundWithBlock {
    //                            (success, error) in
    //                            if success == true {
    //                                self.classes = Array<String>()
    //                                self.cells = Array<UITableViewCell>()
    //                                self.editButtons = Array<UIButton>()
    //                                self.doneButtons = Array<UIButton>()
    //                                self.classTextFields = Array<UITextField>()
    //                                self.classLabels = Array<UILabel>()
    //                                self.activeClassLabels = Array<UILabel>()
    //
    //                                self.getCurrUserObject()
    ////                                self.tableView.reloadData()
    //                            } else {
    //
    //                            }
    //                        }
    //
    //                    }
    //                }
    //            } else {
    //                // Log details of the failure
    //                print("Error: \(error!) \(error!.userInfo)")
    //            }
    //        }
    //
    //        }
    //
    //    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if ((indexPath as NSIndexPath).row == 0) {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row == 0 {
            return
        }
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object.remove(self.classes[(indexPath as NSIndexPath).row - 1], forKey: "user_courses")
                        object.saveInBackground(withTarget: nil, selector: nil)
                        self.classes = Array<String>()
                        self.cells = Array<UITableViewCell>()
                        self.editButtons = Array<UIButton>()
                        self.doneButtons = Array<UIButton>()
                        self.classTextFields = Array<UITextField>()
                        self.classLabels = Array<UILabel>()
                        self.activeClassLabels = Array<UILabel>()
                        self.getCurrUserObject()
                    }
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        
    }
    
    func editButtonPressed(_ sender: UIButton) {
        editMode = true
        editButton.alpha = 0
        self.saveButton.alpha = 1
        self.plusButton.isHidden = false
        self.plusButton.alpha = 1
        for classTextField in self.classTextFields {
            classTextField.isHidden = false
            classTextField.alpha = 1
            classTextField.removeFromSuperview()
        }
        for classLabel in self.classLabels {
            classLabel.alpha = 0
            classLabel.isHidden = true
            classLabel.removeFromSuperview()
        }
        self.cells = Array<UITableViewCell>()
        self.editButtons = Array<UIButton>()
        self.doneButtons = Array<UIButton>()
        self.classTextFields = Array<UITextField>()
        self.classLabels = Array<UILabel>()
        self.activeClassLabels = Array<UILabel>()
        self.tableView.reloadData()
    }
    
    func doneButtonPressed(_ sender: UIButton) {
        self.view.bringSubview(toFront: editButton)
        saveButton.alpha = 0
        let currButtonIndex = sender.tag
        let currEditButton = editButtons[currButtonIndex]
        let currDoneButton = doneButtons[currButtonIndex]
        let currClassTextField = classTextFields[currButtonIndex]
        let currClassLabel = classLabels[currButtonIndex]
        currClassLabel.text = currClassTextField.text
        currClassTextField.isHidden = true
        currDoneButton.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            currDoneButton.alpha = 0
            currEditButton.alpha = 1
            currClassTextField.alpha = 0
            currClassLabel.alpha = 1
        })
        
    }
    
    func plusButtonPressed(_ sender: UIButton) {
        print("pressing plus button")
        plusButton.removeFromSuperview()
        classes.append("")
        var updatedClasses = Array<String>()
        for label in classLabels {
            label.removeFromSuperview()
        }
        
        for textField in classTextFields {
            print("removing from superview " + textField.text!)
            updatedClasses.append(textField.text!)
            print("updated classes are")
            print(updatedClasses)
            textField.removeFromSuperview()
        }
        
        
        
        for i in 0..<updatedClasses.count {
            //if classLabels[i].alpha != 0 {
            //print("alpha is not 0")
            print("updated class " + updatedClasses[i])
            
            classTextFields[i].text = updatedClasses[i]
            
            //                if updatedClasses.contains(classTextFields[i].text!) == false {
            //                    print(classTextFields[i].text!)
            //                    updatedClasses.append(classTextFields[i].text!)
            //                }
            
            //                if activeClassLabels[i].alpha != 0 {
            //                    currActiveClass = classLabels[i].text!
            //                }
            //}
            //if classTextFields[i].alpha != 0 {
            //                if updatedClasses.contains(classTextFields[i].text!) == false {
            //                    updatedClasses.append(classTextFields[i].text!)
            //                }
            
            //}
        }
        
        
        
        
        self.cells = Array<UITableViewCell>()
        self.editButtons = Array<UIButton>()
        self.doneButtons = Array<UIButton>()
        self.classTextFields = Array<UITextField>()
        self.classLabels = Array<UILabel>()
        self.activeClassLabels = Array<UILabel>()
        print("before ", classTextFields.count)
        print("before updated classes are")
        print(updatedClasses)
        print("and classes are")
        print(classes)
        
        for className in classes {
            if className == "" {
                let classIndex = classes.index(of: className)
                if updatedClasses.count > classIndex {
                    classes[classIndex!] = updatedClasses[classIndex!]
                }
            }
        }
        
        
        
        tableView.reloadData()
        print("after ", classTextFields.count)
        print("updated classes after are")
        print(updatedClasses)
        //
        //        if currActiveClass == "nil" {
        //            currActiveClass = (classLabels.first?.text)!
        //        }
        //
        //        for (var i = 0; i < classLabels.count; i += 1) {
        //
        //        }
        //        for classTextField in classTextFields {
        //            if classTextField.hidden == false {
        //                classLabels[classTextFields.indexOf(classTextField)!].text = classTextField.text
        //            }
        //
        //            classTextField.hidden = true
        //            classTextField.alpha = 0
        //        }
        
        
        
        
        
        //
        //        UIView.animateWithDuration(0.25, animations: {
        //            for classTextField in self.classTextFields {
        //                classTextField.hidden = false
        //                classTextField.alpha = 1
        //                classTextField.placeholder = "<your class here>"
        //            }
        //            for classLabel in self.classLabels {
        //                classLabel.alpha = 0
        //                classLabel.hidden = true
        //            }
        //        })
        
    }
    
    func saveClasses() {
        editMode = false
        self.plusButton.isHidden = true
        self.plusButton.alpha = 0
        self.editButton.isHidden = false
        self.editButton.alpha = 1
        HUD.textLabel.text = "Saving..."
        HUD.show(in: view)
        var updatedClasses = Array<String>()
        //var currActiveClass = ""
        for i in 0 ..< classLabels.count {
            if classLabels[i].alpha != 0 {
                if updatedClasses.contains(classLabels[i].text!) == false {
                    updatedClasses.append(classLabels[i].text!)
                }
                
                if activeClassLabels[i].alpha != 0 {
                    currActiveClass = classLabels[i].text!
                }
            }
            if classTextFields[i].alpha != 0 {
                if updatedClasses.contains(classTextFields[i].text!) == false {
                    updatedClasses.append(classTextFields[i].text!)
                }
                
            }
        }
        
        if currActiveClass == "nil" {
            currActiveClass = (classLabels.first?.text)!
        }
        
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["user_courses"] = updatedClasses
                        object["activeClass"] = self.currActiveClass
                        object.saveInBackground(withTarget: nil, selector: nil)
                        self.classes = updatedClasses
                        self.saveButton.alpha = 0
                        self.HUD.dismiss()
                    }
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        for classLabel in classLabels {
            classLabel.isHidden = false
            classLabel.alpha = 1
        }
        
        for classTextField in classTextFields {
            if classTextField.isHidden == false {
                classLabels[classTextFields.index(of: classTextField)!].text = classTextField.text
            }
            
            classTextField.isHidden = true
            classTextField.alpha = 0
        }
        //        self.cells = Array<UITableViewCell>()
        //        self.editButtons = Array<UIButton>()
        //        self.doneButtons = Array<UIButton>()
        //        self.classTextFields = Array<UITextField>()
        //        self.classLabels = Array<UILabel>()
        //        self.activeClassLabels = Array<UILabel>()
        //        tableView.reloadData()
        
    }
    
    
    func activeClassQuery(_ className: String) {
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["activeClass"] = className
                        object.saveInBackground(withTarget: nil, selector: nil)
                    }
                    self.cells = Array<UITableViewCell>()
                    self.editButtons = Array<UIButton>()
                    self.doneButtons = Array<UIButton>()
                    self.classTextFields = Array<UITextField>()
                    self.classLabels = Array<UILabel>()
                    self.activeClassLabels = Array<UILabel>()
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        tableView.reloadData()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //    func beganKeyboardNotifications() {
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    //    }
    
    
    //    func endKeyboardNotifications() {
    //        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    //        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    //    }
    
    //    func keyboardWasShown(notification: NSNotification) {
    //        self.tableView.scrollEnabled = true
    //        var userInfo : NSDictionary = notification.userInfo!
    //        var keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
    //        var insets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
    //
    //        self.tableView.contentInset = insets
    //        self.tableView.scrollIndicatorInsets = insets
    //
    //        var rect : CGRect = self.view.frame
    //        rect.size.height -= keyboardSize!.height
    //        if let activeFieldPresent = activeField {
    //            if (!CGRectContainsPoint(rect, activeField!.frame.origin))
    //            {
    //                self.tableView.scrollRectToVisible(activeField!.frame, animated: true)
    //            }
    //        }
    //
    //
    //    }
    
    
    //    func keyboardWillBeHidden(notification: NSNotification) {
    //        var userInfo : NSDictionary = notification.userInfo!
    //        var keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
    //        var insets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -(keyboardSize!.height + 50), 0.0)
    //        self.tableView.contentInset = insets
    //        self.tableView.scrollIndicatorInsets = insets
    //        self.view.endEditing(true)
    //        self.tableView.scrollEnabled = false
    //
    //    }
    
    
    //    func textFieldDidEndEditing(textField: UITextField!) {
    //        activeField = nil
    //    }
    //
    //    func dismissKeyboard() {
    //        activeField!.resignFirstResponder()
    //    }
    func showContentAlert() {
        
        var subtitleText = "Please make sure that you do not share any content that could be offensive to others and that you conduct yourself on this app in a friendly manner. Groupit does not tolerate any form of bullying or offensive content. If you violate these rules, you may be permanently banned from this app."
        
        var popupTitleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width - 40, height: 40))
        var popupOkayButton = UIButton()
        var popupSubtitleLabel = UILabel()
        
        popupTitleLabel.font = UIFont.systemFont(ofSize: 15)
        popupTitleLabel.textColor = Constants.lightGreenColor
        popupTitleLabel.textAlignment = .center
        popupTitleLabel.text = "USER CONTENT AGREEMENT"
        popupSubtitleLabel.font = UIFont.systemFont(ofSize: 15)
        popupSubtitleLabel.text = subtitleText
        popupSubtitleLabel.adjustsFontSizeToFitWidth = true
        var contentString = subtitleText
        var maximumLabelSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 78, height: 1000)
        var options: NSStringDrawingOptions = [.truncatesLastVisibleLine, .usesLineFragmentOrigin]
        var attr : [String: AnyObject] = [NSFontAttributeName:  UIFont.systemFont(ofSize: 15)]
        var labelBounds: CGRect = contentString.boundingRect(with: maximumLabelSize, options: options, attributes: attr, context: nil)
        var labelHeight: CGFloat = labelBounds.size.height
        popupSubtitleLabel.lineBreakMode = .byWordWrapping
        popupSubtitleLabel.numberOfLines = 0
        
        
        popupSubtitleLabel.frame = CGRect(x: 10, y: 45, width: Int(UIScreen.main.bounds.width) - 40, height: Int(labelHeight))
        var popupViewHeight = 10 + popupTitleLabel.frame.height + 5 + popupSubtitleLabel.frame.height + 10 + 40 + 10
        popupView.frame = CGRect(x: 10, y: (UIScreen.main.bounds.height-popupViewHeight)/2, width: UIScreen.main.bounds.width - 20, height: popupViewHeight)
        popupOkayButton.frame = CGRect(x: 10, y: popupView.frame.height - 50, width: popupView.frame.width - 20, height: 40)
        popupOkayButton.setTitle("OKAY, GOT IT", for: UIControlState())
        popupOkayButton.setTitleColor(UIColor.white, for: UIControlState())
        popupOkayButton.titleLabel?.textColor = Constants.lightGreenColor
        popupOkayButton.titleLabel!.font = UIFont(name: "Gujarati Sangam MN", size: 20)
        popupOkayButton.backgroundColor = Constants.lightGreenColor
        popupOkayButton.addTarget(self, action: #selector(MyProfileViewController.dismissAlert), for: .touchUpInside)
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
    
    func dismissAlert() {
        showAlert = false
        dismissPopupView()
    }
    
}
