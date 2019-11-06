//
//  Wrapper.swift
//  goJekTest
//
//  Created by Nikolay S on 18.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class Wrapper: NSObject {
    static let sharedInstance = Wrapper()
    
    private func responceStatusCode(statusCode: Int) -> Bool {
         switch statusCode {
         case 400, 401, 403, 404: //200, 201, 204, 205, 302, 400, 401, 403, 404, 500:
             return false
         default:
             return true
         }
     }
    
    func requestGetUrl(_ strURL: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
      
         Alamofire.request(strURL).responseJSON { (responseObject) -> Void in
             
             if responseObject.result.isSuccess {
                 let resJson = JSON(responseObject.result.value!)
                 success(resJson)
             }
//             if responseObject.response != nil {
//                 guard self.responceStatusCode(statusCode: responseObject.response!.statusCode) != false else {
//                     let jsonString:String = "{\"success\" : \"Server\"}"
//                     let serverJson:JSON = JSON(parseJSON: jsonString)
//                     success(serverJson)
//                     return
//                 }
//             }

             if responseObject.result.isFailure {
                 let error : Error = responseObject.result.error!
                 failure(error)
             }
         }
     }
        
    func requestGetUrlParams(_ strURL : String, params : [String : Any]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        Alamofire.request(strURL, method: .get, parameters: params).responseJSON { (responseObject) -> Void in
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    func editContact(_ strURL : String, params : [String : Any]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
          
          Alamofire.request(strURL, method: .put, parameters: params, encoding: JSONEncoding.default).responseJSON { (responseObject) -> Void in
             
              if responseObject.result.isSuccess {
                  let resJson = JSON(responseObject.result.value!)
                  success(resJson)
              }
              if responseObject.result.isFailure {
                  let error : Error = responseObject.result.error!
                  failure(error)
              }
          }
      }
    
    func creatNewContact(_ strURL : String, params : [String : Any]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
         
         Alamofire.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (responseObject) -> Void in
            
             if responseObject.result.isSuccess {
                 let resJson = JSON(responseObject.result.value!)
                 success(resJson)
             }
             if responseObject.result.isFailure {
                 let error : Error = responseObject.result.error!
                 failure(error)
             }
         }
     }
}
