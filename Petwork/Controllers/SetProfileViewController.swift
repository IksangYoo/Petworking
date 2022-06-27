//
//  SetProfileViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/31.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SetProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var getStartedButton: UIButton!
    let imagePicker = UIImagePickerController()
    var email : String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        aboutMeTextView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        aboutMeTextView.layer.borderWidth = 1
        aboutMeTextView.text = "About Me"
        aboutMeTextView.textColor = UIColor.lightGray
        getStartedButton.isEnabled = false
    }
    
    
    @IBAction func getStartedPressed(_ sender: UIButton) {
        makeUserProfile()
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func userNameChanged(_ sender: UITextField) {
        checkForValidForm()
    }
    
    
    func checkForValidForm() {
        if let userName = userNameTextField.text, let profileImage = profileImageView.image {
            if userName.count > 0 && profileImage != nil{
                getStartedButton.isEnabled = true
            } else {
                getStartedButton.isEnabled = false
            }
        }
    }
    
    func makeUserProfile() {
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let e = error {
//                print(e.localizedDescription)
//                print("sign up error")
//            } else {
//                let profileImagePath = (authResult?.user.uid)! + "+profileImage"
//                let uid = authResult?.user.uid
//                let imageData = self.profileImageView.image?.jpegData(compressionQuality: 0.1)
//                let storage = Storage.storage().reference()
//                print(profileImagePath)
//
//                storage.child("userProfileImages").child(profileImagePath).putData(imageData!, metadata: nil) { data, error in
//                    storage.child("userProfileImages").child(profileImagePath).downloadURL { url, error in
//                        let name = self.userNameTextField.text
//                        guard let aboutMe = self.aboutMeTextView.text else { return }
//                        Database.database().reference().child("users").child(uid!).setValue(["name": name!, "profileImageURL": url?.absoluteString, "aboutMe": aboutMe])
//                    }
//                }
//            }
//        }
        let name = userNameTextField.text!
        let profileImage = profileImageView.image!
        var aboutMe : String {
            if aboutMeTextView.textColor == UIColor.lightGray || aboutMeTextView.text == "" {
               return ""
            } else {
                return aboutMeTextView.text
            }
        }
       
        
        Auth.auth().creatUser(withEmail: email, password: password, name: name, profileImage: profileImage, aboutMe: aboutMe) { error in
            if let e = error {
                print(e.localizedDescription)
            }
        }
    }
}

//MARK: - UIPickerController
extension SetProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func setProfileImagePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { UIAlertAction in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [self] UIAlertAction in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            checkForValidForm()
        }
    }
}


//MARK: - UItextViewDelegate - for textView
extension SetProfileViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "About Me"
            textView.textColor = UIColor.lightGray
        }
    }
}

//// make imageView circle
//extension UIImageView {
//    func makeRounded() {
//       self.layer.borderWidth = 1
//      self.layer.borderColor = UIColor.black.cgColor
//        let radius = self.frame.width / 2
//              self.layer.cornerRadius = radius
//              self.layer.masksToBounds = true
//    }
//}
