//
//  ListTableViewCell.swift
//  ParseStarterProject
//
//  Created by Akkshay Khoslaa on 12/6/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var cellProfilePic: UIImageView!
    @IBOutlet weak var cellNameLabel: UILabel!
    
    @IBOutlet weak var greenDotFriend: UIImageView!
    @IBOutlet weak var cellDistance: UILabel!
    @IBOutlet weak var cellActiveClass: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
