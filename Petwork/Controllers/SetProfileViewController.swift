//
//  SetProfileViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/31.
//

import UIKit
import Firebase

class SetProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var getStartedButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        aboutMeTextView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        aboutMeTextView.layer.borderWidth = 1
        aboutMeTextView.text = "About Me"
        aboutMeTextView.textColor = UIColor.lightGray
        getStartedButton.isEnabled = false
    }
    
    @IBAction func setProfileImagePressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func getStartedPressed(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func userNameChanged(_ sender: UITextField) {
        checkUserNameTFIsEmpty()
    }
    
    
    func checkUserNameTFIsEmpty() {
        if let userName = userNameTextField.text {
            if userName.count > 0 {
                getStartedButton.isEnabled = true
            } else {
                getStartedButton.isEnabled = false
            }
        }
    }
}


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

// make imageView circle
extension UIImageView {
    func makeRounded() {
       self.layer.borderWidth = 1
//        self.layer.masksToBounds = false
      self.layer.borderColor = UIColor.black.cgColor
//        self.layer.cornerRadius = self.frame.height / 2
//        self.clipsToBounds = true
        let radius = self.frame.width / 2
              self.layer.cornerRadius = radius
              self.layer.masksToBounds = true
    }
}
