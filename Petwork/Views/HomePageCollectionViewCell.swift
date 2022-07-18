//
//  HomePageCollectionViewCell.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/16.
//

import UIKit
import Kingfisher

class HomePageCollectionViewCell: UICollectionViewCell {

    
    let images = (1..<19).map { UIImage(named: "img_movie_\($0)") }
    var post : Post?

    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var nameLebel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var postScrollView: UIScrollView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        postScrollView.delegate = self
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        
//    }
    
    override func prepareForReuse() {
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
    }
}


extension HomePageCollectionViewCell: UIScrollViewDelegate {
    
    func addImages(imageURLs: [String]) {
        
        for i in 0..<imageURLs.count {
            let imageView = UIImageView()
            let xPos = self.contentView.frame.width * CGFloat(i)
            let url = URL(string: imageURLs[i])
            imageView.frame = CGRect(x: xPos, y: 0, width: postScrollView.bounds.width, height: postScrollView.bounds.height)
            imageView.kf.setImage(with: url)
            postScrollView.addSubview(imageView)
            
            postScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        pageControl.numberOfPages = imageURLs.count
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    
//    func addImagesToScrollView(post: Post) {
//        var images : [UIImage] = []
//        
//        for i in 0..<post.postImageURLs.count {
//            let url = URL(string: post.postImageURLs[i])
//            let resource = ImageResource(downloadURL: url!)
//            
//            
//            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
//                
//                switch result {
//                case .success(let value):
//                    images.append(value.image)
//                    
//                case .failure(let error):
//                    print("Error: \(error)")
//                }
//                print("------->\(images)")
//                
////                let imageView = UIImageView()
////                let xPos = self.contentView.frame.width * CGFloat(i)
////                imageView.frame = CGRect(x: xPos, y: 0, width: self.postScrollView.bounds.width, height: self.postScrollView.bounds.height)
////                imageView.image = images[i]
////                self.postScrollView.addSubview(imageView)
////                self.postScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
////                print("-------->\(images.count)")
//            }
//        }
//        pageControl.numberOfPages = images.count
//    }
    //
    //        for i in 0..<images.count {
    //            let imageView = UIImageView()
    //            let xPos = self.contentView.frame.width * CGFloat(i)
    //            imageView.frame = CGRect(x: xPos, y: 0, width: postScrollView.bounds.width, height: postScrollView.bounds.height)
    //            imageView.image = images[i]
    //            postScrollView.addSubview(imageView)
    //            postScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
    //            print("-------->\(images.count)")
    //        }
    
}

