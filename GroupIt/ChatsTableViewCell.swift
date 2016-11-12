//
//  ChatsTableViewCell.swift
//  ParseStarterProject
//
//  Created by Tarun Khasnavis on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var daysAgo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
