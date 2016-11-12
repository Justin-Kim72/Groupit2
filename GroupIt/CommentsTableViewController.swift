//
//  CommentsTableViewController.swift
//  GroupIt
//
//  Created by Ally Koo on 4/24/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse

class CommentsTableViewController: UITableViewController {

    var postInfo: PFObject!
    var commentObjects = Array<PFObject>()
    var textfield: UITextField!
    var sendButton: UIButton!
    var posterObject: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getComment()
    
        textfield = UITextField(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: UIScreen.main.bounds.width, height: 30))
        textfield.borderStyle = .bezel
        textfield.placeholder = "Comment"
        self.view.addSubview(textfield)
        self.view.bringSubview(toFront: textfield)
        
        sendButton = UIButton(type: UIButtonType.system) as UIButton
        sendButton.frame = CGRect(x: UIScreen.main.bounds.width - 30, y: UIScreen.main.bounds.height - 30, width: 30, height: 30)
        sendButton.backgroundColor = UIColor.blue
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.addTarget(self, action: "buttonAction:", for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(sendButton)
        self.view.bringSubview(toFront: sendButton)
        //textfield.addSubview(CommentsTableViewController)
//        tableView.registerClass(HeaderCommentTableViewCell.self, forCellWithReuseIdentifier: "headerCommentCellNew")
        
        
        
        
        tableView.register(HeaderCommentTableViewCell.self, forCellReuseIdentifier: "headerCommentCell2")
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentObjects.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCommentCell2", for: indexPath) as! HeaderCommentTableViewCell

        if (indexPath as NSIndexPath).row == 0 {
            cell.awakeFromNib()
            cell.classTitle.text = postInfo["classTitle"] as! String
            cell.classTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 17.0)
            cell.postBodyText.text = postInfo["message"] as! String
            //cell.profPic. = postInfo["profilePic"]
            //cell.postBodyText.layer.borderWidth = 1
//            let fixedWidth = cell.postBodyText.frame.size.width
//            cell.postBodyText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//            let newSize = cell.postBodyText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//            var newFrame = cell.postBodyText.frame
//            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//            cell.postBodyText.frame = newFrame;
            
            MDBSwiftUtils.formatMultiLineLabel(cell.postBodyText)
            let labelWidth = UIScreen.main.bounds.width - 90
            let labelHeight = MDBSwiftUtils.getMultiLineLabelHeight(postInfo["message"] as! String, maxWidth: Int(labelWidth), font: UIFont.systemFont(ofSize: 14))
            cell.postBodyText.frame = CGRect(x: 60, y: 60, width: labelWidth, height: labelHeight)
            
            cell.profilePic.image = nil
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width/2
            cell.profilePic.clipsToBounds = true

            
            if posterObject != nil {
                MDBSwiftParseUtils.setImageViewImageFromFile(posterObject!["profilePicture"] as! PFFile, imageView: cell.profilePic)
                cell.username.text = posterObject!["username"] as? String
            }

        }else {
            let thecell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentsTableViewCell
            
            if (commentObjects.count >= (indexPath as NSIndexPath).row) {
                print("inside populating comment cell ", self.commentObjects[(indexPath as NSIndexPath).row - 1]["comment"])
                thecell.commentBodyText.text = self.commentObjects[(indexPath as NSIndexPath).row - 1]["comment"] as? String
                thecell.username.text = self.commentObjects[(indexPath as NSIndexPath).row - 1]["username"] as? String
                
                (commentObjects[(indexPath as NSIndexPath).row - 1]["profilePic"] as! PFFile).getDataInBackground ({
                    (imageData: Data?, error: Error?) -> Void in
                    if error == nil {
                        
                        thecell.profPic.image = nil
                        
                        thecell.profPic.image = UIImage(data:imageData!)
                        thecell.profPic.layer.cornerRadius = thecell.profPic.frame.size.width/2
                        thecell.profPic.clipsToBounds = true
                        
                    }
                    
                })
                if commentObjects.count != 0 {
                var timePassedString = ""
                var postTime:Date? = commentObjects[(indexPath as NSIndexPath).row - 1].createdAt!
                var currDate = Date()
                var passedTime:TimeInterval = currDate.timeIntervalSince(postTime!)
                if Double(passedTime) < 60.0 {
                    timePassedString = String(Int(Double(passedTime)))
                    if (Int(Double(passedTime)) == 1) {
                        timePassedString += " sec ago"
                    } else {
                        timePassedString += " secs ago"
                    }
                } else if Double(passedTime) < 3600.0 {
                    timePassedString = String(Int(Double(passedTime)/60))
                    if (Int(Double(passedTime)/60) == 1) {
                        timePassedString += " min ago"
                    } else {
                        timePassedString += " mins ago"
                    }
                } else if Double(passedTime) < 86400.0 {
                    timePassedString = String(Int(Double(passedTime)/3600))
                    if (Int(Double(passedTime)/3600) == 1) {
                        timePassedString += " hr ago"
                    } else {
                        timePassedString += " hrs ago"
                    }
                } else {
                    timePassedString = String(Int(Double(passedTime)/86400.0))
                    if (Int(Double(passedTime)/86400.0) == 1) {
                        timePassedString += " day ago"
                    } else {
                        timePassedString += " days ago"
                    }
                }
                thecell.timePosted.text = timePassedString
                }
            }
            
            
            }

        return cell
    }
    
    func getComment() {
        commentObjects = Array<PFObject>()
        let query = PFQuery(className: "Comments")
        print("object ID of post is ", self.postInfo["message"])
        query.whereKey("postId", equalTo: postInfo.objectId!)
        //query.findObjectsInBackgroundWithBlock {
            //(objects: [PFObject]?, error: NSError?) -> Void in
        do {
            let objects = try query.findObjects()
            
            // The find succeeded.
            print("Successfully retrieved \(objects.count) users.")
            // Do something with the found objects
            if let objects = objects as? [PFObject] {
                print("COUNT", objects.count)
                self.commentObjects = objects
                for object in self.commentObjects {
                    print(object["comment"])
                }
                //self.numPosts = objects.count
                //print(self.postObjects)
                
                //for postObject in self.postObjects {
                //self.nameToUserDict[userObject["username"] as! String] = postObject
                //}
                //self.membersTableView.reloadData()
                
                self.tableView!.reloadData()
            }
            
        }
        catch {
            print("oops exception")
        }
    }

    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            MDBSwiftUtils.formatMultiLineLabel()
//            //let labelWidth = UIScreen.mainScreen().bounds.width - 90
//            let labelHeight = MDBSwiftUtils.getMultiLineLabelHeight(postInfo["message"] as! String, maxWidth: Int(labelWidth), font: UIFont.systemFontOfSize(14))
//            //cell.postBodyText.frame = CGRectMake(60, 60, labelWidth, labelHeight)
//            return labelHeight
//        } else {
//            MDBSwiftUtils.formatMultiLineLabel(cell.postBodyText)
//            //let labelWidth = UIScreen.mainScreen().bounds.width - 90
//            let labelHeight = MDBSwiftUtils.getMultiLineLabelHeight(commentObjects[indexPath.row]["comment"] as! String, maxWidth: Int(labelWidth), font: UIFont.systemFontOfSize(14))
//            //cell.postBodyText.frame = CGRectMake(60, 60, labelWidth, labelHeight)
//            return labelHeight
//        }
//
//        

        if (indexPath as NSIndexPath).row == 0 {
            return 150
        }
        else {
            return 100
        }
    }
    

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
