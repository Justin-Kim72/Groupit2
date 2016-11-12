//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import STZPopupView


class ViewController: UIViewController, BWWalkthroughViewControllerDelegate {
    let popupView = UIView(frame: CGRect(x: 0, y: 200, width: Int(UIScreen.main.bounds.width), height: Int(3*(((UIScreen.main.bounds.width/320) * 80) + 50))))
    @IBOutlet weak var backgroundImage: UIImageView!
    var performedLogout = false
    @IBOutlet weak var fblogin: UIButton!
    var justSignedUp = false
    @IBAction func loadFBData(_ sender: AnyObject) {
        
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) {
            (user: PFUser?, error: Error?) -> Void in
            if let user = user {
                if user.isNew {
                    self.loadFacebookData() //
                    
                    user["user_courses"] = Array<String>()
                    user["activeClass"] = ""
                    user["status"] = true
                    user["flags"] = 0
                    user["location"] = PFGeoPoint(latitude: 0, longitude: 0)
                    user.saveInBackground(withTarget: nil, selector: nil)
                    
                    
                    print("User signed up and logged in through Facebook!") //
                    //AppDelegate.isFirstTimeUser = 1
                    self.justSignedUp = true
                    
                    
//                    self.tabBarController!.selectedIndex = 3
                } else {
                    //                    self.loadFacebookData()
                    print("User logged in through Facebook!")
                    self.performSegue(withIdentifier: "toTabBarVC", sender: self)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTabBarVC" && justSignedUp == true {
            let destVC = segue.destination as! UITabBarController
            destVC.selectedIndex = 2
            let destinationViewController = destVC.viewControllers![2] as! UINavigationController
            let finalVC = destinationViewController.topViewController as! MyProfileViewController
            finalVC.showAlert = true
        }
    }
    
    
    
    
    func animatedLogin() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 7, options: UIViewAnimationOptions.curveEaseIn , animations: ({
            
            self.fblogin.alpha = 1
            
        }), completion: nil)
    }
    
    
    
    
    func loadFacebookData() {
        let user =  PFUser.current()!
        
        // -------------------- Load and save user Information -------------------------------------
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                if let userName : NSString = (result as AnyObject).value(forKey: "username") as? NSString {
                    print("User Name is: \(userName)")
                    user["username"] = userName
                } else {print("No username fetched")}
                if let userEmail : NSString = (result as AnyObject).value(forKey: "email") as? NSString {
                    print("User Email is: \(userEmail)")
                    user["email"] = userEmail
                } else  {print("No email address fetched")}
                if let userGender : NSString = (result as AnyObject).value(forKey: "gender") as? NSString {
                    print("User Gender is: \(userGender)")
                    user["gender"] = userGender
                } else {print("No gender fetched") }
                
                user.saveInBackground(block: { (success, error) -> Void in
                    if success == false{
                        print("Error")
                    } else {
                        print("User Information has been saved successfully!")
                    }
                })
            }
        })
        
        
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
        
        pictureRequest?.start(completionHandler: { (connection, result, error) in
            let result = result as! [String:AnyObject]
            if error == nil {
                if let profilePicURL : String  = (result["data"] as! [String:AnyObject])["url"] as? String {
                    print("The profile picture url is: \(profilePicURL)")
                    let url = URL(string: profilePicURL)
                    let urlRequest = URLRequest(url: url!)
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: OperationQueue.main, completionHandler: {
                        (response, data, error) in
                        
                        let image = UIImage(data: data!)
                        
                        
                        
                        // ------------------ save image as png in Parse --------------------
                        let imageFile = PFFile(name: "profpic.png", data: UIImagePNGRepresentation(image!)!)
                        //                        let imageData = UIImagePNGRepresentation(self.profilePic.image)
                        
                        let friendRecord = PFObject(className: "friends")
                        friendRecord["username"] = PFUser.current()!.username! as String
                        friendRecord["profpic"] = imageFile
                        
                        friendRecord.saveInBackground(withTarget: nil, selector: nil)
                        
                        user["profilePicture"] = imageFile
                        
                        user.saveInBackground(block: { (success, error) -> Void in
                            if success == false{
                                print("Could not Save User Image")
                            } else {
                                self.performSegue(withIdentifier: "toTabBarVC", sender: self)
                                print("ProfilePic has been saved successfully!")
                            }
                        })
                    })
                    
                } else { print("No profile pic URL fetched") }
            } else {
                print("\(error)")
            }
        })
        //        performSegueWithIdentifier("introSeg", sender: self)
    }
    
    //THE FOLLOWING WAS COMMENTED OUT BY SONA BC IT WAS CRASHING THE APP.
    
    override func viewDidAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "tutorialPresented")
        {
            showContentAlert()
            
            userDefaults.set(true, forKey: "tutorialPresented")
            userDefaults.synchronize()
        }
        
//        if PFUser.currentUser() != nil {
//            self.performSegueWithIdentifier("toTabBarVC", sender: self)
//        }
    }
    
    func showTutorial()
    {
        // Present Tutorial
        let walkthroughVC = self.storyboard?.instantiateViewController(withIdentifier: "walkthrough") as! BWWalkthroughViewController
        
        let pageOne = self.storyboard?.instantiateViewController(withIdentifier: "pageOne")
        let pageTwo = self.storyboard?.instantiateViewController(withIdentifier: "pageTwo")
        let pageThree = self.storyboard?.instantiateViewController(withIdentifier: "pageThree")
        let pageFour = self.storyboard?.instantiateViewController(withIdentifier: "pageFour")
        
        walkthroughVC.delegate = self
        walkthroughVC.addViewController(pageOne!)
        walkthroughVC.addViewController(pageTwo!)
        walkthroughVC.addViewController(pageThree!)
        walkthroughVC.addViewController(pageFour!)
        self.present(walkthroughVC, animated: true, completion: nil)
        
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fblogin.alpha = 0
        self.animatedLogin()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        //self.backgroundImage.image = UIImage(named: "login_green")
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "purple")!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        popupOkayButton.addTarget(self, action: #selector(ViewController.dismissAlert), for: .touchUpInside)
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
        dismissPopupView()
        showTutorial()
    }
    
}

