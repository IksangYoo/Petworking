//
//  PostViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/25.
//

import UIKit
import Kingfisher

class PostViewController: UIViewController {

    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setupView()
    }
    
    func setupView() {
        
        guard let post = post else { return }
        let user = post.user
        let profileURL = URL(string: user.profileImageURL)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        
        fetchImageToScrollView()
        nameLabel.text = user.name
        profileImageView.kf.setImage(with: profileURL)
        captionTextView.isUserInteractionEnabled = false
        captionTextView.text = post.caption
        dateLabel.text = dateFormatter.string(from: post.creationDate)
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
    }
}

//MARK: - ScrollView Delegate
extension PostViewController: UIScrollViewDelegate {
    
    func fetchImageToScrollView() {
        guard let postURLs = post?.postImageURLs else { return }
        
        for i in 0..<postURLs.count {
            let imageView = UIImageView()
            let xPos = self.view.frame.width * CGFloat(i)
            let url = URL(string: postURLs[i])
            imageView.frame = CGRect(x: xPos, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
            imageView.kf.setImage(with: url)
            scrollView.addSubview(imageView)
            scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        pageControl.numberOfPages = postURLs.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
}
