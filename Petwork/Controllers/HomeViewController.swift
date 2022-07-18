//
//  HomeViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import Firebase
import Kingfisher

class HomeViewController: UIViewController {
    
    var posts = [Post]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        collectionView.register(UINib(nibName: "HomePageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeCell")
        super.viewDidLoad()
        
        fetchPosts { results in
            self.posts = results
            self.collectionView.reloadData()
        }
    }
    
//    func fetchUsersPosts() {
//
//        let userDBRef = Database.database().reference().child("users")
//        let postRef = Database.database().reference().child("posts")
//
//        userDBRef.observeSingleEvent(of: .value) { snapshot in
//            guard let userDict = snapshot.value as? [String: Any] else { return }
//            userDict.forEach { key, value in
//                let user = User(uid: key, dictionary: value as! [String : Any])
//
//                postRef.child(user.uid).observeSingleEvent(of: .value) { snapshot in
//                    guard let postDict = snapshot.value as? [String: Any] else { return }
//                    postDict.forEach { key, value in
//                        let post = Post(user: user, dictionary: value as! [String: Any])
//
//                        self.posts.append(post)
//                        self.collectionView.reloadData()
//                    }
//                }
//            }
//        }
//    }
    
    
    
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {

        let userDBRef = Database.database().reference().child("users")
        let postRef = Database.database().reference().child("posts")

        var results = [Post]()  // <-- here
        let dispatch = DispatchGroup()  // <-- here

        dispatch.enter()  // <-- A
        userDBRef.observeSingleEvent(of: .value) { snapshot in
            guard let userDict = snapshot.value as? [String: Any] else {
                dispatch.leave() // <-- A
                return
            }

            userDict.forEach { key, value in
                let user = User(uid: key, dictionary: value as! [String : Any])
                dispatch.enter()  // <-- B
                postRef.child(user.uid).observeSingleEvent(of: .value) { snapshot in
                    guard let postDict = snapshot.value as? [String: Any] else {
                        dispatch.leave() // <-- B
                        return
                    }
                    postDict.forEach { key, value in
                        let post = Post(user: user, dictionary: value as! [String: Any])
                        results.append(post)
                    }
                    dispatch.leave() // <-- B
                }
            }

            dispatch.leave() // <-- A
        }

        dispatch.notify(queue: .main) {
            completion(results.sorted(by: { p1, p2 in
                p1.creationDate > p2.creationDate
            }))
        }
        
    }

}

//MARK: - collectionView

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as? HomePageCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
//        cell.post = posts[indexPath.item]
        let post = posts[indexPath.item]
        let url = URL(string: post.user.profileImageURL)!
        cell.profileImageView.kf.setImage(with: url)
        cell.nameLebel.text = post.user.name
        cell.addImages(imageURLs: post.postImageURLs)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height : CGFloat
        
        height = width / 7 * 10
        print(width)
        return CGSize(width: width, height: height)
    }
    
}
