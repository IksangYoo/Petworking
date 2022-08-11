//
//  ViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/14.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
//import AuthenticationServices
//import CryptoKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
   
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    private var currentNonce: String?
    
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
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
        self.view.endEditing(true)
    }
    
    @IBAction func googleLoginPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func facebookLoginPressed(_ sender: UIButton) {
        facebookLogin()
    }
    
    func facebookLogin() {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if error != nil {
                return
            }
            guard let token = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in

                guard let isNewUser = result?.additionalUserInfo?.isNewUser else { return }
                guard let user = result?.user else { return }
                guard let profileURL = user.photoURL else { return }
                let urlString = profileURL.absoluteString
                
                if isNewUser {
                    Database.database().reference().child("users").child(user.uid).setValue(["name": user.displayName!, "profileImageURL": urlString, "aboutMe": "Please Set About Me"])
                }

                if let error = error {
                    print ("Error Facebook sign in: %@", error)
                    return
                }

                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
}

//extension LoginViewController: UITextFieldDelegate {
//    
//    // keyboard dismiss when touch outside
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    
//    // keyboard dismiss when press return
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}


//Apple Login flow

//extension LoginViewController: ASAuthorizationControllerDelegate {
//
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
//
//            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
//
//            Auth.auth().signIn(with: credential) { result, error in
//
//                guard let isNewUser = result?.additionalUserInfo?.isNewUser else { return }
//                guard let user = result?.user else { return }
//
//                if isNewUser {
//                    Database.database().reference().child("users").child(user.uid).setValue(["name": user.displayName, "profileImageURL": "", "aboutMe": "Please Set About Me"])
//                }
//
//                if let error = error {
//                    print ("Error Apple sign in: %@", error)
//                    return
//                }
//
//                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }
//        }
//    }
//
//    func startSignInWithAppleFlow() {
//            let nonce = randomNonceString()
//            currentNonce = nonce
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            let request = appleIDProvider.createRequest()
//            request.requestedScopes = [.fullName, .email]
//            request.nonce = sha256(nonce)
//
//            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//            authorizationController.delegate = self
//            authorizationController.presentationContextProvider = self
//            authorizationController.performRequests()
//        }
//
//        private func sha256(_ input: String) -> String {
//            let inputData = Data(input.utf8)
//            let hashedData = SHA256.hash(data: inputData)
//            let hashString = hashedData.compactMap {
//                return String(format: "%02x", $0)
//            }.joined()
//
//            return hashString
//        }
//
//        // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
//        private func randomNonceString(length: Int = 32) -> String {
//            precondition(length > 0)
//            let charset: Array<Character> =
//                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//            var result = ""
//            var remainingLength = length
//
//            while remainingLength > 0 {
//                let randoms: [UInt8] = (0 ..< 16).map { _ in
//                    var random: UInt8 = 0
//                    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//                    if errorCode != errSecSuccess {
//                        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//                    }
//                    return random
//                }
//
//                randoms.forEach { random in
//                    if remainingLength == 0 {
//                        return
//                    }
//
//                    if random < charset.count {
//                        result.append(charset[Int(random)])
//                        remainingLength -= 1
//                    }
//                }
//            }
//
//            return result
//        }
//}

//extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//}
