//
//  Commet.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/26.
//

import Foundation

struct Comment: Equatable {
    let user: User
    let text: String
    let uid: String
    let creationDate: Date
    let autoID: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.autoID = dictionary["autoID"] as? String ?? ""
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.autoID == rhs.autoID
    }
}
