//
//  User.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/06/27.
//

import Foundation

struct User {
    let uid : String
    let name : String
    let aboutMe: String
    var profileImageURL: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        name = dictionary["name"] as? String ?? ""
        aboutMe = dictionary["aboutMe"] as? String ?? ""
        profileImageURL = dictionary["profileImageURL"] as? String ?? ""
    }
}
