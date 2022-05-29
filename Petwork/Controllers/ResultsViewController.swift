//
//  ResultsViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit

class ResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var searchTerm: String = ""
    let images = (1..<19).map { UIImage(named: "img_movie_\($0)") }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = "Results for \(searchTerm)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedImageCell", for: indexPath) as? FeedImageCell
        else {
            return UICollectionViewCell()
        }
        cell.feedImage.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width ) / 3
        let height = width
        
        
        return CGSize(width: width, height: height)
        
    }
    
}

class FeedImageCell: UICollectionViewCell {
    @IBOutlet weak var feedImage: UIImageView!
}
