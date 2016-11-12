//
//  ForumCollectionViewCell.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/21/16.
//  Copyright © 2016 Sona and Ally. All rights reserved.
//

import UIKit

class ForumCollectionViewCell: UICollectionViewCell {
    
    var profPic: UIImageView!
    var username: UILabel!
    var postMainText: UILabel!
    var postBodyText: UILabel!
    var timePosted: UILabel!
    
    override func awakeFromNib() {
        profPic = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        profPic.contentMode = .scaleAspectFill
        profPic.layer.cornerRadius = profPic.frame.width/2
        profPic.clipsToBounds = true
        self.contentView.addSubview(profPic)
        
        username = UILabel(frame: CGRect(x: 60, y: 10, width: UIScreen.main.bounds.width - 40 - 60, height: 20))
        username.font = UIFont.boldSystemFont(ofSize: 14)
        self.contentView.addSubview(username)
        
        postBodyText = UILabel(frame: CGRect(x: 60, y: 55, width: UIScreen.main.bounds.width - 20, height: 20))
        postBodyText.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(postBodyText)
        
        postMainText = UILabel(frame: CGRect(x: 60, y: 28, width: UIScreen.main.bounds.width - 40 - 60, height: 20))
        postMainText.font = UIFont.systemFont(ofSize: 12)
        postMainText.textColor = UIColor.gray
        self.contentView.addSubview(postMainText)
        
        timePosted = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 95, y: 10, width: 60, height: 30))
        timePosted.font = UIFont.systemFont(ofSize: 10)
        timePosted.textAlignment = .right
        timePosted.textColor = UIColor.lightGray
        self.contentView.addSubview(timePosted)
        
        self.backgroundColor = UIColor.white
        
        
    }
    
    
    
    
    
}
