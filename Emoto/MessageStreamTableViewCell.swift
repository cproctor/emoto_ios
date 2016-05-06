//
//  MessageStreamTableViewCell.swift
//  Emoto
//
//  Created by Chris Proctor on 5/6/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class MessageStreamTableViewCell: UITableViewCell {

    @IBOutlet weak var emoto: UIImageView!
    @IBOutlet weak var messageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
