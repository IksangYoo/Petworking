//
//  SignUpViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/17.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmErrorLabel: UILabel!
    @IBOutlet weak var checkBox: CheckBox!
    var changedIsChecked = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWelcome" {
            let destinationVC = segue.destination as! SetProfileViewController
            destinationVC.email = emailTextField.text!
            destinationVC.password = passwordTextField.text!
        }
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continuePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: "goToWelcome", sender: self)
    }
    
    @IBAction func checkBoxPressed(_ sender: UIButton) {
        changedIsChecked = !checkBox.isChecked
        checkForValidForm()
    }
    
    func defaultForm() {
        continueButton.isEnabled = false
        
        emailErrorLabel.isHidden = false
        passwordErrorLabel.isHidden = false
        confirmErrorLabel.isHidden = false
        
        emailErrorLabel.text = "Required"
        passwordErrorLabel.text = "Required"
        confirmErrorLabel.text = "Required"
    }
    
    @IBAction func emailChanged(_ sender: UITextField) {
        if let email = emailTextField.text {
            if let errorMessage = invalidEmail(email) {
                emailErrorLabel.text = errorMessage
                emailErrorLabel.isHidden = false
            } else {
                emailErrorLabel.isHidden = true
            }
        }
        checkForValidForm()
    }
    
    func invalidEmail(_ value: String) -> String? {
        let regularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regularExpression)
        if !predicate.evaluate(with: value) {
            return "Invalid Email Address"
        }
        return nil
    }
    
    @IBAction func passwordChanged(_ sender: UITextField) {
        if let password = passwordTextField.text {
            if let errorMessage = invalidPassword(password) {
                passwordErrorLabel.text = errorMessage
                passwordErrorLabel.isHidden = false
            } else {
                passwordErrorLabel.isHidden = true
            }
        }
        checkForValidForm()
    }
    
    func invalidPassword(_ value: String) -> String? {
            if value.count < 6{
                return "Password must be at least 6 characters"
            }
//            if containsDigit(value){
//                return "Password must contain at least 1 digit"
//            }
//            if containsLowerCase(value){
//                return "Password must contain at least 1 lowercase character"
//            }
//            if containsUpperCase(value){
//                return "Password must contain at least 1 uppercase character"
//            }
            return nil
        }
        
//        func containsDigit(_ value: String) -> Bool
//        {
//            let reqularExpression = ".*[0-9]+.*"
//            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
//            return !predicate.evaluate(with: value)
//        }
        
//        func containsLowerCase(_ value: String) -> Bool
//        {
//            let reqularExpression = ".*[a-z]+.*"
//            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
//            return !predicate.evaluate(with: value)
//        }
//
//        func containsUpperCase(_ value: String) -> Bool
//        {
//            let reqularExpression = ".*[A-Z]+.*"
//            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
//            return !predicate.evaluate(with: value)
//        }
    
    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        if let confirmPassword = confirmPasswordTextField.text {
            if let errorMessage = invalidConfirmPassword(confirmPassword) {
                confirmErrorLabel.text = errorMessage
                confirmErrorLabel.isHidden = false
            } else {
                confirmErrorLabel.isHidden = true
            }
        }
        checkForValidForm()
    }
    
    func invalidConfirmPassword(_ value: String) -> String? {
            if value != passwordTextField.text {
                return "Password does not match"
            }
        return nil
    }
    
    func checkForValidForm() {
        if emailErrorLabel.isHidden && passwordErrorLabel.isHidden && confirmErrorLabel.isHidden && changedIsChecked
        {
            continueButton.isEnabled = true
        }
        else
        {
            continueButton.isEnabled = false
        }
    }
}
    // checkbox
    
class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "icon.checked")! as UIImage
    let uncheckedImage = UIImage(named: "icon.unchecked")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
