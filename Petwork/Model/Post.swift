//
//  Post.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/04.
//

import Foundation

struct Post: Equatable {
    
    let user: User
    let autoID: String?
    let postImageURLs: [String]
    let caption: String
    let creationDate: Date
    let tags: [String]
    
    init(user: User, dictionary: [String: Any]){
        
        self.user = user
        self.autoID = dictionary["autoID"] as? String ?? ""
        self.postImageURLs = dictionary["postImageURLs"] as? [String] ?? []
        self.caption = dictionary["caption"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.tags = dictionary["tags"] as? [String] ?? []
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.autoID == rhs.autoID
    }
}
