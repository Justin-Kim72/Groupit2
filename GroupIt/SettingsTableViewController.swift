//
//  SettingsTableViewController.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/2/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import JGProgressHUD
import Parse

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var statusToggle: UISwitch!
    var timer: Timer?
    
    @IBOutlet weak var distanceSlider: UISlider!
    

    @IBAction func sliderDidChange(_ sender: UISlider) {
        
        let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.light)
        
//        distanceSlider.minimumValue = 30
//        distanceSlider.minimumValue = 5280
//        distanceSlider.continuous = true
        
        //HUD.textLabel.text = String(format: "Radius set to %X feet", distanceSlider.value)
        
        let selectedValue = Float(sender.value)
        HUD.textLabel.text = "Radius set to " + String(stringInterpolationSegment: selectedValue) + " feet"
        
        
        
        //HUD.textLabel.text = "Radius set to" + String(lroundf(distanceSlider.value)) + "feet"
        HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        HUD.show(in: self.view!)
        HUD.dismiss(afterDelay: 1.0)
        
        
        
    }
    
    @IBAction func switchDidChange(_ sender: AnyObject) {
        
        if self.statusToggle.isOn {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: "getAndSaveLocation", userInfo: nil, repeats: true)
            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.light)
            HUD.textLabel.text = "Online"
            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            HUD.show(in: self.view!)
            HUD.dismiss(afterDelay: 1.0)
            
        }
        else {
            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.light)
            HUD.textLabel.text = "Offline"
            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            HUD.show(in: self.view!)
            HUD.dismiss(afterDelay: 1.0)
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
                        if self.statusToggle.isOn {
                            object["status"] = true
                        }
                        else
                        {
                            object["status"] = false
                        }
                        
                        object.saveInBackground(withTarget: nil, selector: nil)
                        
                        
                    }
                }
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    //override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return 0
    //}

    //override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 0
    //}

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
