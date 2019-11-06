//
//  ContactTableViewCell.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var imageUserView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageUserView.layer.cornerRadius = self.imageUserView.frame.height/2
        self.imageUserView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
