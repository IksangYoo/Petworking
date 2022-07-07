//
//  Post.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/04.
//

import Foundation

struct Post {
    var id: String?
    let user: User
    let imageURLs: [String]
    let caption: String
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]){
        self.user = user
        self.imageURLs = dictionary["url"] as? [String] ?? []
        self.caption = dictionary["caption"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}