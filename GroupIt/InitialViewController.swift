//
//  InitialViewController.swift
//  GroupIt
//
//  Created by Akkshay Khoslaa on 4/27/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse
class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            self.performSegue(withIdentifier: "initialToLogin", sender: self)
        } else {
            self.performSegue(withIdentifier: "initialToTabBar", sender: self)
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
