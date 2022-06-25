//
//  ViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/14.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.shadowColor = UIColor.black.cgColor
    }


    
    
    @IBAction func loginPressed(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}
