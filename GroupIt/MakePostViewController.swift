//
//  MakePostViewController.swift
//  GroupIt
//
//  Created by Akkshay Khoslaa on 4/27/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD
class MakePostViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    var textView: UITextView!
    var segControl: UISegmentedControl!
    var classes = Array<String>()
    var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrUserClasses()
        setupNavBar()
        setupTextView()
    }
    
    func setupSegControl() {
        segControl = UISegmentedControl(items: classes)
        segControl.frame = CGRect(x: 10, y: 35 + self.navigationController!.navigationBar.frame.height, width: UIScreen.main.bounds.width - 20, height: 30)
        segControl.selectedSegmentIndex = 0
        segControl.layer.cornerRadius = 5.0
        segControl.tintColor = Constants.appBlueCOlor
        self.view.addSubview(segControl)
    }
    
    func getCurrUserClasses() {
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) classes.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        
                        let currUserObject = objects.first
                        
                        if currUserObject!["user_courses"] != nil {
                            
                            self.classes = currUserObject!["user_courses"] as! Array<String>
                            
                            self.setupSegControl()
                            
                        } else {
                            //Tell the user to add their classes
                        }
                        
                    }
                }
                
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }

    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.tintColor = Constants.appBlueCOlor
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Helvetica", size: 20)!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary

    }
    
    func setupTextView() {
        textView = UITextView(frame: CGRect(x: 10, y: 120, width: UIScreen.main.bounds.width - 20, height: 250))
        textView.font = UIFont(name: "Helvetica", size: 15)
        textView.layer.borderWidth = 0
        textView.textColor = UIColor.lightGray
        textView.layer.cornerRadius = 5
        textView.layer.backgroundColor = Constants.lightGrayColor.cgColor
        textView.delegate = self
        textView.text = "Share your thoughts here"
        textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.text == "Share your thoughts here"){
            textView.text = ""
            textView.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Share your thoughts here"
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPost(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendPost(_ sender: AnyObject) {
        
        if textView.text == "" || textView.text == "Share your thoughts here" {
            MDBSwiftUtils.showBasicAlert("Cannot Post", content: "Please enter something to post.", currVC: self)
        } else {
            HUD.textLabel.text = "Posting..."
            HUD.show(in: view)
            let postObject = PFObject(className: "Forum")
            postObject["poster"] = PFUser.current()?.objectId
            postObject["message"] = textView.text
            postObject["comments"] = Array<String>()
            postObject["classTitle"] = classes[segControl.selectedSegmentIndex]
            postObject.saveInBackground {
                (success: Bool, error: Error?) -> Void in
                if (success) {
                    self.HUD.dismiss()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.HUD.dismiss()
                }
            }
        }
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
