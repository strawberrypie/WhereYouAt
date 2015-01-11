//
//  UserCell.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2014-12-30.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImage: FBProfilePictureView!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //let theWitdh = UIScreen.mainScreen().bounds.width
        
        //contentView.frame = CGRectMake(10, 10, theWitdh, 120)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
