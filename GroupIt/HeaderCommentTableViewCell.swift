//
//  HeaderCommentTableViewCell.swift
//  GroupIt
//
//  Created by Ally Koo on 4/24/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit

class HeaderCommentTableViewCell: UITableViewCell {
    
    var profilePic: UIImageView!
    var username: UILabel!
    var classTitle: UILabel!
    var postBodyText: UILabel!

    
    override func awakeFromNib() {
        profilePic = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        profilePic.contentMode = .scaleAspectFill
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        profilePic.clipsToBounds = true
        self.contentView.addSubview(profilePic)
        
        username = UILabel(frame: CGRect(x: 80, y: 10, width: UIScreen.main.bounds.width - 40 - 60, height: 20))
        username.font = UIFont.boldSystemFont(ofSize: 14)
        self.contentView.addSubview(username)
        
        postBodyText = UILabel(frame: CGRect(x: 80, y: 60, width: UIScreen.main.bounds.width - 20, height: 20))
        postBodyText.font = UIFont.systemFont(ofSize: 14)
        
        self.contentView.addSubview(postBodyText)
        
        classTitle = UILabel(frame: CGRect(x: 80, y: 25, width: UIScreen.main.bounds.width - 40 - 60, height: 20))
        classTitle.font = UIFont.systemFont(ofSize: 12)
        classTitle.textColor = UIColor.gray
        self.contentView.addSubview(classTitle)
    }
    
//    override func awakeFromNib() {
//        postBodyText.editable = false
//        super.awakeFromNib()
//        // Initialization code
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}

