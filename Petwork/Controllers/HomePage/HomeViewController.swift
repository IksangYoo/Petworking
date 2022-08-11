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
    
    var index : IndexPath?
    var user : User?
    var posts = [Post]()
    var currentUser : User?
    
    @IBOutlet weak var collectionView: UICollectionView!
    let refresh = UIRefreshControl()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "HomePageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeCell")
        retrieveCurrentUser()
        fetchPosts { results in
            self.posts = results
            self.collectionView.reloadData()
        }
        initRefresh()
    }
    
    
    
    func initRefresh() {
        collectionView.refreshControl = refresh
        collectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        fetchPosts { results in
            self.posts = results
            self.collectionView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refresh.endRefreshing()
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUser" {
            let destinationVC = segue.destination as! UserViewController
            destinationVC.user = user
        }
    }
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        let userDBRef = Database.database().reference().child("users")
        let postRef = Database.database().reference().child("posts")
//        guard let blockedUser = currentUser?.blockedUser else { return }
        
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
                        if !self.currentUser!.blockedUser.contains(post.user.uid) {
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
        fetchPostToCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        user = posts[indexPath.item].user
        performSegue(withIdentifier: "goToUser", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height : CGFloat
        height = width / 7 * 10
        
        return CGSize(width: width, height: height)
    }
    
    func fetchPostToCell(cell: HomePageCollectionViewCell, indexPath: IndexPath){
        let post = posts[indexPath.item]
        let url = URL(string: post.user.profileImageURL)
        let imageURLs = post.postImageURLs
        let scrollView = cell.postScrollView!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        cell.post = post
        cell.profileImageView.kf.setImage(with: url)
        cell.nameLebel.text = post.user.name
        cell.captionTextView.text = post.caption
        cell.creationDateLabel.text = dateFormatter.string(from: post.creationDate)
        
        
        for i in 0..<imageURLs.count {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            let xPos = self.view.frame.width * CGFloat(i)
            let url = URL(string: imageURLs[i])
            imageView.frame = CGRect(x: xPos, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
            imageView.kf.setImage(with: url)
            scrollView.addSubview(imageView)
            scrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        cell.pageControl.numberOfPages = imageURLs.count
    }
}
