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
            guard let firstImageURL = post?.url[0] else { return }
            postImageView.loadImage(urlString: firstImageURL)
        }
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var postImageView: CustomImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        print("delete")
    }
}
