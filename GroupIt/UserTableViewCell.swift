//
//  UserTableViewCell.swift
//  GroupIt
//
//  Created by Akkshay Khoslaa on 4/25/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    var profPicImageView: UIImageView!
    var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        profPicImageView = UIImageView(frame: CGRect(x: 10, y: 5, width: 40, height: 40))
        profPicImageView.clipsToBounds = true
        profPicImageView.layer.cornerRadius = profPicImageView.frame.width/2
        profPicImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(profPicImageView)
        
        
        usernameLabel = UILabel(frame: CGRect(x: 55, y: 15, width: UIScreen.main.bounds.width - 40, height: 20))
        usernameLabel.font = UIFont(name: "Helvetica", size: 14)
        self.contentView.addSubview(usernameLabel)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
