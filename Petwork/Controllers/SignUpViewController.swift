//
//  SignUpViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/17.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
        print(isChecked)
    }
}
