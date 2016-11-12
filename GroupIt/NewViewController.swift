//
//  NewViewController.swift
//  ParseStarterProject
//
//  Created by Riley Edmunds on 11/7/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse


class NewViewController: UIViewController {
    
    @IBOutlet weak var goList: UIBarButtonItem!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var myPicture: UIImage!

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var firstClassLabel: UILabel!
    @IBOutlet weak var classOne: UITextField!
    
    @IBOutlet weak var classTwo: UITextField!
    @IBOutlet weak var secondClassLabel: UILabel!
    
    @IBOutlet weak var classThree: UITextField!
    @IBOutlet weak var thirdClassLabel: UILabel!
    
    @IBOutlet weak var classFour: UITextField!
    @IBOutlet weak var fourthClassLabel: UILabel!
    
    @IBOutlet weak var updateClasses: UIButton!
    @IBOutlet weak var background: UIImageView!
        var currUserClasses = Array<String>()
    var fullName = String()
    var classArray = Array<String>()
    
    @IBOutlet weak var berkeleyBg: UIImageView!
    @IBAction func goList(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toListView", sender: self)

    }
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = CGRect(x: 0, y: 0, width: 320, height: 160)
        
        berkeleyBg.addSubview(effectView)

        self.navigationController!.navigationBar.isHidden = false
        //        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 0.459, green: 0.102, blue: 1, alpha: 1)
        self.navigationController!.navigationBar.barTintColor = UIColor.purple
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        self.navigationController!.navigationBar.tintColor = UIColor.white
       //print(self.classOne)
        //self.getFBName() //name populate from parse
        self.getFBpicture() // picture populates from parse
        
        //self.initializeNilClasses()  // or self.initializeNilClasses1() //if user is new, make parse classes nil
        self.getClassData() //user courses populate from parse
        
        usernameLabel.text = PFUser.current()?.username
        
        classOne.isHidden = true
        classTwo.isHidden = true
        classThree.isHidden = true
        classFour.isHidden = true
    }


    @IBAction func classOneTextField(_ sender: AnyObject) {
        
    }

    

    
    @IBAction func updateClasses(_ sender: AnyObject) {
        self.pushClassData() //pushes current inputs in class fields to parse
//        self.getClassData() //change the local fields to the new values we input
    }
    
    
    
    func getClassData() {  //pulls the courses from parse and binds them to course labels
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        do {
        let objects = try query.findObjects()
            for object in objects {
                if object["user_courses"] != nil {
                    self.currUserClasses = object["user_courses"] as! Array
                }
                if self.currUserClasses.count >= 1 {
                    print("got here")
                    print(self.currUserClasses[0])
                    firstClassLabel?.text = self.currUserClasses[0]
                }
                if self.currUserClasses.count >= 2 {
                    self.secondClassLabel?.text = self.currUserClasses[1]
                }
                if self.currUserClasses.count >= 3 {
                    self.thirdClassLabel?.text = self.currUserClasses[2]
                }
                if self.currUserClasses.count >= 4 {
                    self.fourthClassLabel?.text = self.currUserClasses[3]
                }
                else {
                    print("hey it's all nil in here")
                    firstClassLabel.text = "No Classes Saved"
                    secondClassLabel.isHidden = true
                    thirdClassLabel.isHidden = true
                    fourthClassLabel.isHidden = true
                }
            }
                      
        } catch {
            print("Error")
        }
    }
    
    
    
    func getFBName() {  //pulls the facebook name from parse and binds it to the name label
        let query = PFQuery(className: "User")
        do {
            let objects = try query.findObjects()  //objects are
            self.usernameLabel.text = objects[0]["username"] as? String
        } catch {
            print("Error")
        }
    }



    func getFBpicture() {  //pulls the profile picture from parse and binds it to local userPhoto variable
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        do {
            let objects = try query.findObjects()
            let imageFile =  objects[0]["profilePicture"] as! PFFile
            imageFile.getDataInBackground{ (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    let image1 = UIImage(data: imageData!)
                    self.profilePic.image = image1
                    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
                    self.profilePic.clipsToBounds = true
                }
            }
        } catch {
            print("Error")
        }
    }

    
    func pushClassData() {
        var updatedClasses = Array<String>()
        updatedClasses.append(classOne.text!)
        updatedClasses.append(classTwo.text!)
        updatedClasses.append(classThree.text!)
        updatedClasses.append(classFour.text!)
        
        let query = PFQuery(className:"_User")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        object["user_courses"] = updatedClasses
                        object.saveInBackground(withTarget: nil, selector: nil)
                        
                    }
                    
                    self.currUserClasses = updatedClasses
                }
            }
            
         else {
                // Log details of the failure
                print("error")
            }
        }
    
        
    
    }
    
    
    @IBAction func editClasses(_ sender: AnyObject) {
        classOne.isHidden = false
        classTwo.isHidden = false
        classThree.isHidden = false
        classFour.isHidden = false
        firstClassLabel.isHidden = true
        secondClassLabel.isHidden = true
        thirdClassLabel.isHidden = true
        fourthClassLabel.isHidden = true
        
    }
    
    
    
    
    
    
    
    
    
    
    //--------------------------------------------------------------
    
    
    //    func initializeNilClasses1() {
    //        var query = PFQuery(className: "User")
    //        do {
    //            let objects = try query.findObjects()  //objects are
    //            for object in objects {
    //                if (PFUser.currentUser()?.objectId)! == object["objectId"] as! String {
    //                    print("existing user, no need to set nil classes")
    //                }
    //            }
    //            self.setNilClasses()
    //        }
    //        catch {
    //            print("Error")
    //        }
    //
    //    }
    
    
//    
//    func initializeNilClasses() {
//        let query = PFQuery(className:"User")
//        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//            
//            if error == nil {
//                // The find succeeded.
//                print("Successfully retrieved scores.")
//                // Do something with the found objects
//                if let objects = objects! as? [PFObject] {
//                    for object in objects {
//                        if (PFUser.currentUser()?.objectId)! == object["objectId"] as! String {
//                            return }
//                        else {
//                            self.setNilClasses()
//                        }
//                    }
//                }
//                
//            } else {
//                // Log details of the failure
//                print("Error")
//            }
//        }
//        
//        
//    }
//    
//    
//    
//    
//    func setNilClasses() {
//        let query = PFQuery(className:"User")
//        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
//            
//            if error == nil {
//                // The find succeeded.
//                print("Successfully retrieved scores.")
//                // Do something with the found objects
//                if let objects = objects! as? [PFObject] {
//                    for object in objects { //for each user
//                        //                    object["user_courses"][0] = "a" //set the first element of their class_array to nil
//                        //                    object["user_courses"][1] = nil                 //set the second as well.. so forth
//                        //                    object["user_courses"][2] = nil
//                        //                    object["user_courses"][3] = nil
//                        
//                        object.saveInBackgroundWithTarget(nil , selector: nil)
//                    }
//                }
//            }
//                
//            else {
//                // Log details of the failure
//                print("Error")
//            }
//        }
//    }
    
    
    
    //    func setNilClasses() {
    //        var query = PFQuery(className: "User")
    //        do {
    //            let objects = try query.findObjects()  //objects are
    //            objects[0]["user_courses"] = "a"
    //            objects[1]["user_courses"] = "a"
    //            objects[2]["user_courses"] = "a"
    //            objects[3]["user_courses"] = "a"
    //        }
    //         catch {
    //            print("Error")
    //        }
    //    }

    
    
   override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
