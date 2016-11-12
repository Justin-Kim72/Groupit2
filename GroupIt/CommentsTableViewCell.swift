//
//  CommentsTableViewCell.swift
//  GroupIt
//
//  Created by Ally Koo on 4/24/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse

class CommentsTableViewCell: UITableViewCell {


    var profPic: UIImageView!
    var username: UILabel!
    var commentBodyText: UILabel!
    var timePosted: UILabel!
    
    
    override func awakeFromNib() {
        profPic = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        profPic.contentMode = .scaleAspectFill
        profPic.layer.cornerRadius = profPic.frame.width/2
        profPic.clipsToBounds = true
        self.contentView.addSubview(profPic)
        
        username = UILabel(frame: CGRect(x: 80, y: 10, width: UIScreen.main.bounds.width - 40 - 60, height: 20))
        username.font = UIFont.boldSystemFont(ofSize: 14)
        self.contentView.addSubview(username)
        
        commentBodyText = UILabel(frame: CGRect(x: 80, y: 60, width: UIScreen.main.bounds.width - 20, height: 20))
        commentBodyText.font = UIFont.systemFont(ofSize: 14)
        
        self.contentView.addSubview(commentBodyText)
        
        timePosted = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 95, y: 10, width: 60, height: 30))
        timePosted.font = UIFont.systemFont(ofSize: 10)
        timePosted.textAlignment = .right
        timePosted.textColor = UIColor.lightGray
        self.contentView.addSubview(timePosted)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
