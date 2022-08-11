//
//  HomePageCollectionViewCell.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/16.
//

import UIKit
import Kingfisher

class HomePageCollectionViewCell: UICollectionViewCell {
    var post : Post?

    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var nameLebel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var postScrollView: UIScrollView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImageView.isUserInteractionEnabled = true
        postScrollView.showsHorizontalScrollIndicator = false
        postScrollView.showsVerticalScrollIndicator = false
//        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        captionTextView.isUserInteractionEnabled = false
        postScrollView.delegate = self
    }
    
//    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
//        print(post?.user.name)
//    }
    
    override func prepareForReuse() {
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
    }
//
//    func fetchCurrentUser() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let dbRef = Database.database().reference().child("users").child(uid)
//
//        dbRef.observeSingleEvent(of: .value) { snapshot in
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//            self.user = User(uid: uid, dictionary: dictionary)
//            self.blockedUser = self.user!.blockedUser
//        }
//    }
//
//    @IBAction func optionsPressed(_ sender: UIButton) {
//        let alert = UIAlertController(title: "Report", message: "", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Block User", style: .destructive, handler: { action in
//            self.blockUser()
//        }))
//        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { action in
//            // report post
//        }))
//
//        homeViewController.present(alert, animated: true)
//    }
}



extension HomePageCollectionViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
}

