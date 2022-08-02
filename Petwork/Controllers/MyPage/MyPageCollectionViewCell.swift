//
//  MyPageCollectionViewCell.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/06.
//

import UIKit

class MyPageCollectionViewCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let firstImageURL = post?.postImageURLs[0] else { return }
            postImageView.loadImage(urlString: firstImageURL)
        }
    }
    
    @IBOutlet weak var postImageView: CustomImageView!
    @IBOutlet weak var xButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
