//
//  ContactInfoTableViewCell.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import UIKit

class ContactInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImage.layer.cornerRadius = self.userImage.frame.height/2
        self.userImage.layer.masksToBounds = true
        
        self.userImage.layer.borderColor = UIColor.white.cgColor
        self.userImage.layer.borderWidth = 2.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
