//
//  ResultsViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit

class ResultsViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var segmentIndex = 0
    var searchTerm: String = ""
    let images = (1..<19).map { UIImage(named: "img_movie_\($0)") }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = "Results for \(searchTerm)"
        collectionView.register(UINib(nibName: "ResultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "feedCell")
    }
    
    @IBAction func switchDisplayMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            segmentIndex = sender.selectedSegmentIndex
            collectionView.reloadData()
        } else {
            segmentIndex = sender.selectedSegmentIndex
            collectionView.reloadData()
        }
    }
    
}

extension ResultsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as? ResultCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.feedImageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.width
        let height : CGFloat
        let inset : CGFloat = 2
        
        if segmentIndex == 0 {
            width = (width / 3) - inset * 2
            height = width
            return CGSize(width: width, height: height)
        } else {
            height = width
            return CGSize(width: width, height: height)
        }
    }
}
