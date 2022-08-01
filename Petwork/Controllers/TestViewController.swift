//
//  TestViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/31.
//

import UIKit

class TestViewController: UIViewController {
  
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil)
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil)
    }
 
//    @objc private func keyboardWillShow(_ notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
//                return
//        }
//
//        let contentInset = UIEdgeInsets(
//            top: 0.0,
//            left: 0.0,
//            bottom: keyboardFrame.size.height,
//            right: 0.0)
//        scrollView.contentInset = contentInset
//        scrollView.scrollIndicatorInsets = contentInset
//    }
//    @objc private func keyboardWillHide() {
//        let contentInset = UIEdgeInsets.zero
//        scrollView.contentInset = contentInset
//        scrollView.scrollIndicatorInsets = contentInset
//    }
}
