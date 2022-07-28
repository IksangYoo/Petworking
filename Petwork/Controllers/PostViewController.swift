//
//  PostViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/25.
//

import UIKit
import Kingfisher
import Firebase

class PostViewController: UIViewController {

    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var noCommentsLabel: UILabel!
    
    var post : Post?
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setupView()
        fetchComments()
        deleteObserver()
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
        commentTextField.placeholder = "Add a Comment"
        commentTextField.textColor = UIColor.lightGray
    }
    
    func uploadComment() {
        guard let commentText = commentTextField.text else { return }
        guard let post = post else { return }
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let dbRef = Database.database().reference().child("comments").child(post.autoID).childByAutoId()
        guard let autoID = dbRef.key else { return }
        
        dbRef.updateChildValues(["uid": currentUserUid, "text": commentText, "autoID": autoID ,"creationDate": Date().timeIntervalSince1970])
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        uploadComment()
        commentTextField.text = ""
        commentTextField.placeholder = "Add a Comment"
    }
    
    func fetchComments() {
        guard let post = post else { return }
        let dbRef = Database.database().reference().child("comments").child(post.autoID)
        comments.removeAll()
        
        dbRef.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid) { user in
                let comment = Comment(user: user, dictionary: dictionary)
                
                if !self.comments.contains(comment) {
                    self.comments.append(comment)
                }
                self.comments.sort { c1, c2 in
                    c1.creationDate > c2.creationDate
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteObserver() {
        guard let post = post else { return }
        let dbRef = Database.database().reference().child("comments").child(post.autoID)

        dbRef.observe(.childRemoved) { snapshot in
            print("delete")
            self.fetchComments()
            self.tableView.reloadData()
        }
    }
}

// tag 받아오기. [String] -> String으로 convert 하기.


//MARK: - UITableViewDataSource
extension PostViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? commentCell else {
            return UITableViewCell()
        }
        let comment = comments[indexPath.item]
        let urlString = comment.user.profileImageURL
        let url = URL(string: urlString)
        cell.postId = post!.autoID
        cell.comment = comment
        cell.profileImageView.kf.setImage(with: url)
        cell.commentTextLabel.text = comment.text
        
        return cell
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

//MARK: - UITextFieldDelegate
extension PostViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        commentTextField.text = ""
        commentTextField.textColor = .black
    }
}

class commentCell: UITableViewCell {
    let postVC = PostViewController()
    var postId : String = ""
    var comment: Comment?
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let comment = comment else { return }
        
        let dbRef = Database.database().reference().child("comments").child(postId).child(comment.autoID)
        dbRef.removeValue()
        
    }
    
}
