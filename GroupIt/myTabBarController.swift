//
//  myTabBarController.swift
//  
//
//  Created by Riley Edmunds on 1/22/16.
//
//

import UIKit

class MyTabBarController: UITabBarController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        
            // Sets the default color of the icon of the selected UITabBarItem and Title
            UITabBar.appearance().tintColor = UIColor.red
        
        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = UIColor.black
        
        // Sets the background color of the selected UITabBarItem (using and plain colored UIImage with the width = 1/5 of the tabBar (if you have 5 items) and the height of the tabBar)
//        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(UIColor.blueColor(), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))
        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
//        for item in self.tabBar.items as! [UITabBarItem] {
//            if let image = item.image {
//                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
//            }
//        }
    }
    

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
