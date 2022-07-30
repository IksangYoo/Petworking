//
//  ViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/14.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.shadowColor = UIColor.black.cgColor
        loginButton.isEnabled = true
    }

    @IBAction func googleLoginPressed(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func emailChanged(_ sender: UITextField) {
        checkForValidForm()
    }
    
    @IBAction func passwordChanged(_ sender: UITextField) {
        checkForValidForm()
    }
    
    func checkForValidForm() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if email.count > 0 && password.count > 0 {
                loginButton.isEnabled = true
            } else {
                loginButton.isEnabled = false
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}
