//
//  Reqest.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Reqest: NSObject {
    static let sharedInstance = Reqest()
    private var contactRlm = myRealm?.objects(ContactRealm.self)
    private var contactsArr = [ContactsModel]()
    
    func requestContact(success:@escaping (Bool) -> Void, failure:@escaping (Error) -> Void) {
        
        Wrapper.sharedInstance.requestGetUrl(APIConstants.sharedInstance.baseUrl + "/contacts.json", success: { (json) in
            #if DEBUG
            print(json)
            #endif
            self.contactsArr.removeAll()
            if json.arrayValue.count > 0 {
                for (_, value) in json.arrayValue.enumerated() {
                    let contact = ContactsModel(id: value["id"].intValue,
                                                first_name: value["first_name"].stringValue,
                                                last_name: value["last_name"].stringValue,
                                                profile_pic: value["profile_pic"].stringValue,
                                                favorite: value["favorite"].boolValue,
                                                url: value["url"].stringValue,
                                                email: value["email"].stringValue,
                                                phone: value["phone"].stringValue)
                    self.contactsArr.append(contact)
                }
                self.contactRlm = myRealm!.objects(ContactRealm.self)
                saveContactsToRealm()
            } else {
                #if DEBUG
                print("error json")
                #endif
                let error = NSError(domain:"", code:401, userInfo:[NSLocalizedDescriptionKey: "json contact error"])
                failure(error)
            }
        }) { (error) in
            #if DEBUG
            print(error)
            failure(error)
            #endif
        }
        
        func saveContactsToRealm() {
            if contactsArr.count > 0 {
                if contactRlm?.count ?? 0 > 0 {
                    try! myRealm!.write {
                        myRealm!.delete(contactRlm!)
                    }
                    saveContactsToRealm()
                } else {
                    try! myRealm!.write {
                        
                        for (_, value) in contactsArr.enumerated() {
                            let contactRlm = ContactRealm()
                            contactRlm.id = value.id
                            contactRlm.first_name = value.first_name
                            contactRlm.last_name = value.last_name
                            contactRlm.profile_pic = value.profile_pic
                            contactRlm.favorite = value.favorite
                            contactRlm.url = value.url
                            contactRlm.email = value.email
                            contactRlm.phone = value.phone
                            myRealm!.add(contactRlm)
                        }
                    }
                    #if DEBUG
                    print("************** saveContactRlmToRealm **************")
                    #endif
                    success(true)
                }
            } else {
                success(false)
            }
            success(true)
        }
    }
    
    func requestContactId(_ id: Int, success:@escaping (Bool) -> Void, failure:@escaping (Error) -> Void) {
        self.contactRlm = myRealm!.objects(ContactRealm.self)
        let url = APIConstants.sharedInstance.baseUrl + "/contacts/\(id).json"
        Wrapper.sharedInstance.requestGetUrl(url, success: { (json) in
            #if DEBUG
            print(json)
            #endif
            let contactFltr = self.contactRlm!.filter("id == \(id)")
            let newData = contactFltr.first
            try! myRealm!.write {
                newData!.email = json["email"].stringValue
                newData!.phone = json["phone_number"].stringValue
            }
            success(true)
        }) { (error) in
            #if DEBUG
            print(error)
            failure(error)
            #endif
        }
    }
    
    func requestNewContact(_ params:[String : Any], success:@escaping (Bool) -> Void, failure:@escaping (Error) -> Void) {
        
        let url = APIConstants.sharedInstance.baseUrl + "/contacts.json"
        Wrapper.sharedInstance.creatNewContact(url, params: params, success: { (json) in
            #if DEBUG
            print(json)
            #endif
            success(true)
            
        }) { (error) in
            #if DEBUG
            print(error)
            failure(error)
            #endif
        }
    }
    
    func requestEditContact(_ id: Int, params:[String : Any], success:@escaping (Bool) -> Void, failure:@escaping (Error) -> Void) {
        
        let url = APIConstants.sharedInstance.baseUrl + "/contacts/\(id).json"
        Wrapper.sharedInstance.editContact(url, params: params, success: { (json) in
            #if DEBUG
            print(json)
            #endif
            let contactFltr = self.contactRlm!.filter("id == \(id)")
                       let newData = contactFltr.first
                       try! myRealm!.write {
                            newData!.first_name = json["first_name"].stringValue
                            newData!.last_name = json["last_name"].stringValue
                            newData!.favorite = json["favorite"].boolValue
                            newData!.profile_pic = json["profile_pic"].stringValue
                            newData!.email = json["email"].stringValue
                            newData!.phone = json["phone_number"].stringValue
                       }
            success(true)
            
        }) { (error) in
            #if DEBUG
            print(error)
            failure(error)
            #endif
        }
    }
}
