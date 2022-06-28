//
//  MyPageViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import Firebase
import FirebaseStorage

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    let ref = Database.database().reference()
    let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateForm()
    }
    
    func updateForm() {
        
        aboutMeTextView.isUserInteractionEnabled = false
        
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("users").child(uid!).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: String] else { return }
            if let name = data["name"], let aboutMe = data["aboutMe"], let urlString = data["profileImageURL"]{
                let url = URL(string: urlString)
                let imageData = NSData(contentsOf: url!)
                let image = UIImage(data: imageData! as Data)
                DispatchQueue.main.async {
                    self.nameLabel.text = name
                    self.aboutMeTextView.text = aboutMe
                    self.profileImageView.image = image
                }
            }
        }
    }

//    func downloadImage(uid: String) -> UIImage {
//        let profileImagePath = uid + "+profileImage"
//        storage.child("userProfileImages").child(profileImagePath).downloadURL { url, error in
//            if let e = error {
//                print(e.localizedDescription)
//            } else {
//                let data = NSData(contentsOf: url!)
//                let image = UIImage(data: data! as Data)!
//            }
//        }
//        storage.child("asd").ge
//        return image
//    }
}
