//
//  PostViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/25.
//

import UIKit
import Kingfisher
import Firebase
import IQKeyboardManagerSwift

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
    var currentUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        retrieveCurrentUser()
        setupView()
        fetchComments()
        deleteObserver()
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func setupView() {
        guard let post = post else { return }
        let user = post.user
        let profileURL = URL(string: user.profileImageURL)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let tagString = post.tags.joined(separator: ",")
        
        fetchImageToScrollView()
        nameLabel.text = user.name
        profileImageView.kf.setImage(with: profileURL)
        captionTextView.isUserInteractionEnabled = false
        captionTextView.text = post.caption
        tagLabel.text = tagString
        dateLabel.text = dateFormatter.string(from: post.creationDate)
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        commentTextField.textColor = UIColor.lightGray
        commentTextField.attributedPlaceholder = NSAttributedString(
            string: "Add a Comment",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    func retrieveCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dbRef = Database.database().reference().child("users").child(uid)

        dbRef.observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            self.currentUser = User(uid: uid, dictionary: dict)
        }
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
                    if self.currentUser?.blockedUser == nil {
                        self.comments.append(comment)
                    } else if !self.currentUser!.blockedUser.contains(comment.uid) {
                        self.comments.append(comment)
                    }
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
        if comments.count == 0 {
            noCommentsLabel.isHidden = false
        } else {
            noCommentsLabel.isHidden = true
        }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? commentCell else {
            return UITableViewCell()
        }
        
        cell.comment = comments[indexPath.item]
        setupCell(cell)
        
        return cell
    }
    
    func setupCell(_ cell: commentCell) {
        guard let post = post else { return }
        guard let comment = cell.comment else { return }
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let urlString = comment.user.profileImageURL
        let url = URL(string: urlString)
        
        
        cell.postId = post.autoID
        cell.commentTextLabel.text = comment.text
        cell.profileImageView.kf.setImage(with: url)
        var frame = nameLabel.frame
               frame.size.width = 100
               nameLabel.frame = frame
        cell.nameLabel.text = comment.user.name
        cell.nameLabel.sizeToFit()
        cell.commentTextLabel.numberOfLines = 0
        
        if post.user.uid == currentUID {
            cell.deleteButton.isHidden = false
        } else {
            if comment.uid == currentUID {
                cell.deleteButton.isHidden = false
            } else {
                cell.deleteButton.isHidden = true
            }
        }
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
    // keyboard dismiss when touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // keyboard dismiss when press return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class commentCell: UITableViewCell {
    let postVC = PostViewController()
    var postId : String = ""
    var comment: Comment?
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
//    override func prepareForReuse() {
//        var frame = nameLabel.frame
//        frame.size.width = 100
//        nameLabel.frame = frame
//    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let comment = comment else { return }
        
        let dbRef = Database.database().reference().child("comments").child(postId).child(comment.autoID)
        dbRef.removeValue()
        
    }
}
