//
//  MessageCell.swift
//  WhereYouAt
//
//  Created by Kj Drougge on 2015-01-01.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var senderBtn: UIButton!
    @IBOutlet weak var senderTextView: UITextView!
    
    @IBOutlet weak var receiverBtn: UIButton!
    @IBOutlet weak var receiverTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
