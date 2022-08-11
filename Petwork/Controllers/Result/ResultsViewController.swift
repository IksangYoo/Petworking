//
//  ResultsViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import Firebase
import Kingfisher

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var noResultLabel: UILabel!
    
    var post : Post?
    var posts = [Post]()
    var filteredPosts = [Post]()
    var segmentIndex = 0
    var searchTag: String = ""
    var currentUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ResultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "resultCell")
        retrieveCurrentUser()
        resultLabel.text = "Results for \(searchTag)"
        fetchPosts { result in
            self.posts = result
            self.filterdPostsByTag()
            self.collectionView.reloadData()
        }
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPost" {
            let destinationVC = segue.destination as! PostViewController
            destinationVC.post = post
    }
}
    
    func filterdPostsByTag() {
        if searchTag == "All" {
            filteredPosts = posts
        } else {
            posts.forEach { post in
                if post.tags.contains(searchTag) {
                    filteredPosts.append(post)
                }
            }
        }
        
        if filteredPosts.count != 0 {
            noResultLabel.isHidden = true
        } else {
            noResultLabel.isHidden = false
        }
    }
    
    func retrieveCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dbRef = Database.database().reference().child("users").child(uid)

        dbRef.observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            self.currentUser = User(uid: uid, dictionary: dict)
        }
    }

    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        let userDBRef = Database.database().reference().child("users")
        let postRef = Database.database().reference().child("posts")
        
        var results = [Post]()
        let dispatch = DispatchGroup()
        
        dispatch.enter()
        userDBRef.observeSingleEvent(of: .value) { snapshot in
            guard let userDict = snapshot.value as? [String: Any] else {
                dispatch.leave()
                return
            }
            
            userDict.forEach { key, value in
                let user = User(uid: key, dictionary: value as! [String : Any])
                dispatch.enter()
                postRef.child(user.uid).observeSingleEvent(of: .value) { snapshot in
                    guard let postDict = snapshot.value as? [String: Any] else {
                        dispatch.leave()
                        return
                    }
                    postDict.forEach { key, value in
                        let post = Post(user: user, dictionary: value as! [String: Any])
                        if self.currentUser?.blockedUser == nil {
                            results.append(post)
                        } else if !self.currentUser!.blockedUser.contains(post.user.uid) {
                            results.append(post)
                        }
                    }
                    dispatch.leave()
                }
            }
            dispatch.leave()
        }
        
        dispatch.notify(queue: .main) {
            completion(results.sorted(by: { p1, p2 in
                p1.creationDate > p2.creationDate
            }))
        }
    }
    
}

extension ResultsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultCell", for: indexPath) as? ResultCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let url = URL(string: filteredPosts[indexPath.item].postImageURLs[0])
        cell.feedImageView.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        post = filteredPosts[indexPath.item]
        performSegue(withIdentifier: "goToPost", sender: self)
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
