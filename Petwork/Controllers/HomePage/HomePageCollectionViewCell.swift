//
//  HomePageCollectionViewCell.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/16.
//

import UIKit
import Kingfisher

//protocol homeCellDelegate: NSObjectProtocol {
//    func imagePressed(sender: Any)
//}

class HomePageCollectionViewCell: UICollectionViewCell {
//    var delegate: homeCellDelegate!
    var homeViewController: HomeViewController!
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

