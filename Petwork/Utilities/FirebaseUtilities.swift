//
//  FirebaseUtilities.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/06/27.
//

import Foundation
import Firebase

extension Auth {
    func creatUser(withEmail email: String, password: String, name: String, profileImage: UIImage, aboutMe: String, completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error { completion(e); return }
            guard let uid = authResult?.user.uid else { return }
            
            Storage.storage().uploadUserProfileImage(profileImage: profileImage, uid: uid) { profileImageURL, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    Database.database().reference().child("users").child(uid).setValue(["name": name, "profileImageURL": profileImageURL, "aboutMe": aboutMe])
                }
            }
        }
        
    }
}

extension Storage {
    
    func uploadUserProfileImage(profileImage: UIImage?, uid: String, completion: @escaping (String?, Error?) -> ()) {
        guard let image = profileImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let storageRef = Storage.storage().reference().child("userProfileImages").child(uid)
        
        storageRef.putData(imageData, metadata: nil) { metaData, error in
            if let e = error { completion(nil, e); return }
            
            storageRef.downloadURL { downloadURL, error in
                if let e = error { completion(nil, e); return }
                
                guard let profileImageURL = downloadURL?.absoluteString else { return }
                completion(profileImageURL, nil)
            }
        }
    }
}

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (err) in
            print("Failed to fetch user for posts: ", err)
        }
    }
}
