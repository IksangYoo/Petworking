//
//  UserViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/19.
//

import UIKit
import Firebase
import Kingfisher


class UserViewController: UIViewController {
    
    var posts = [Post]()
    var user : User?
    var segmentIndex = 0
    var post : Post?
    var currentUser : User?
//    var images = [UIImage]()
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        setUserForm()
        retrieveCurrentUser()
        fetchOrderedPosts()
    }
    
    func setUserForm() {
        guard let user = user else { return }
        let url = URL(string: user.profileImageURL)
        profileImageView.kf.setImage(with: url)
        nameLabel.text = user.name
        aboutMeTextView.isUserInteractionEnabled = false
        aboutMeTextView.text = user.aboutMe
        if user.uid == Auth.auth().currentUser?.uid {
            reportButton.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPost" {
            let destinationVC = segue.destination as! PostViewController
            destinationVC.post = post
//            destinationVC.images = images
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
    
    
    func fetchOrderedPosts() {
        guard let user = user else { return }
        let dbRef = Database.database().reference().child("posts").child(user.uid)
        
        dbRef.queryOrdered(byChild: "creationDate").observe( .childAdded) { snapshot in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }
    }
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Report", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Block User", style: .destructive, handler: { action in
            self.blockUserAlert()
        }))
        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { action in
            // report post
        }))
        present(alert, animated: true)
    }
    
    func blockUserAlert() {
        let alert = UIAlertController(title: "", message: "Do you want to block this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.blockUser()
        }))
        present(alert, animated: true)
    }
    
    func blockUser() {
        let dbRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        if !currentUser!.blockedUser.contains(user!.uid) {
            currentUser!.blockedUser.append(user!.uid)
            let alert = UIAlertController(title: "Successfully blocked!", message: "Please login again for updating blocked user", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        
        dbRef.updateChildValues(["blockedUser": currentUser!.blockedUser])
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
    
//    func returnImages(with urls: [String]) -> [UIImage] {
//        var images = [UIImage]()
//
//        urls.forEach { urlString in
//            guard let url = URL(string: urlString) else { return }
//            KingfisherManager.shared.retrieveImage(with: url) { result in
//                switch result {
//                case .success(let value):
//                    images.append(value.image)
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            }
//        }
//
//        return images
//    }
}

extension UserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as? userPostCell
        else {
            return UICollectionViewCell()
        }
        let url = URL(string: posts[indexPath.item].postImageURLs[0])
        cell.postImageView.kf.setImage(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        post = posts[indexPath.item]
        print("---> \(post!.postImageURLs.count)")
//        images = returnImages(with: post!.postImageURLs)
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

class userPostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
}
