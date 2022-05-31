//
//  SetProfileViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/31.
//

import UIKit

class SetProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: CircularImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

  
}

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
