//
//  Profile.swift
//  ProfileView
//
//  Created by User on 5/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Profile {
    
    var id: String
    var name: String
    var age: String
    var gender: String
    var hobby: String
    var bgColor: String
    var image: UIImage
    var imgURL: String
    
    init() {
        self.id = ""
        self.name = ""
        self.age = ""
        self.gender = ""
        self.hobby = ""
        self.bgColor = ""
        self.image = UIImage.init()
        self.imgURL = ""
    }
    
    init(id: String, name: String, age: String, gender: String, hobby: String, image: UIImage, imgURL: String, bgColor: String) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.hobby = hobby
        self.bgColor = bgColor
        self.image = image
        self.imgURL = imgURL
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let id = dictionary["id"] as! String
        let name = dictionary["name"] as! String
        let age = dictionary["age"] as! String
        let gender = dictionary["gender"] as! String
        let hobby = dictionary["hobby"] as! String
        let bgColor = dictionary["bgColor"] as! String
        let imageURL = dictionary["image_URL"] as! String
        
        //Convert from String into Image.
        let decodeData = NSData(base64Encoded: imageURL, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let image = UIImage(data: decodeData! as Data, scale: 1.0)
        
        self.init(id: id, name: name, age: age, gender: gender, hobby: hobby, image: image!, imgURL: imageURL, bgColor: bgColor)
    }
}
