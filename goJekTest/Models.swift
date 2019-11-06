//
//  Models.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import Foundation

struct ContactsModel {
    var id:Int
    var first_name:String
    var last_name:String
    var profile_pic:String
    var favorite:Bool
    var url:String
    var email:String
    var phone:String
    init(id:Int, first_name:String, last_name:String, profile_pic:String, favorite:Bool, url:String, email:String, phone:String) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.profile_pic = profile_pic
        self.favorite = favorite
        self.url = url
        self.email = email
        self.phone = phone
    }
}
