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
    let profileImageURL: String
    var blockedUser : [String]
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        name = dictionary["name"] as? String ?? ""
        aboutMe = dictionary["aboutMe"] as? String ?? ""
        profileImageURL = dictionary["profileImageURL"] as? String ?? ""
        self.blockedUser = dictionary["blockedUser"] as? [String] ?? []
    }
}
