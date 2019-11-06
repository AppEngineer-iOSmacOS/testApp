//
//  RealmModels.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import Foundation
import RealmSwift

class ContactRealm: Object {
    @objc dynamic var id = 0
    @objc dynamic var first_name = ""
    @objc dynamic var last_name = ""
    @objc dynamic var profile_pic = ""
    @objc dynamic var favorite = false
    @objc dynamic var url = ""
    @objc dynamic var email = ""
    @objc dynamic var phone = ""
}

