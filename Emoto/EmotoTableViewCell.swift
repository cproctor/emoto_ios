//
//  EmotoTableViewCell.swift
//  Emoto
//
//  Created by Graduates on 5/8/16.
//  Copyright © 2016 Chris Proctor. All rights reserved.
//

import UIKit

class EmotoTableViewCell: UITableViewCell {

    @IBOutlet weak var imageChoice: UIImageView!
    
    @IBOutlet weak var emotoLabel: UILabel!
    
    @IBOutlet weak var selectedIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedIcon.hidden = !selected
        // Configure the view for the selected state
    }
    

}
