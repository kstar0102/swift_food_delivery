//
//  User.swift
//  Foodsie
//
//  Created by Cons Bulaqueña on 02/06/2018.
//  Copyright © 2018 consios. All rights reserved.
//

import Foundation
import SwiftyJSON

class User
{
    var name: String?
    var email: String?
    var pictureURL: String?
    var id: String?

    
    static let current = User()
    
    func setData(json: JSON)
    {
        name = json["name"].string
        email = json["email"].string
        id = json["id"].string
        
        let imageDictionary = json["picture"].dictionary
        let imageDataDictionary = imageDictionary?["data"]?.dictionary
        pictureURL = imageDataDictionary?["url"]?.string
        
    }
    
    func resetData() {
        name = nil
        email = nil
        pictureURL = nil
        id = nil
    
    }
    
    
    func toDictionary() -> [String: Any]
    {
        return [
            "name" : name!,
            "id" : id!,
            "name" : email!,
            "pictureURL" : pictureURL!
            
        
        ]
    }
}




















