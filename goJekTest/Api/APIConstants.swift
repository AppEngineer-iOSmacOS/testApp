//
//  APIConstants.swift
//  goJekTest
//
//  Created by Nikolay S on 18.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import Foundation


public class APIConstants {
    static let sharedInstance = APIConstants()
    let baseUrl: String = "http://gojek-contacts-app.herokuapp.com"
    
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    

}
