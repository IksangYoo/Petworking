//
//  MyPageViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import Firebase
import FirebaseStorage

class MyPageViewController: UIViewController {
    
    var settingButtonClicked = false
    var segmentIndex = 0
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    var user: User?
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MyPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "postCell")
        fetchUserAndUpdateForm()
        defaultForm()
    }
    
    func defaultForm() {
        aboutMeTextView.isUserInteractionEnabled = false
        nameTF.layer.borderWidth = 0
        nameTF.isUserInteractionEnabled = false
        cameraButton.isHidden = true
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
    }
    
    func settingsForm() {
        aboutMeTextView.isUserInteractionEnabled = true
        nameTF.layer.borderWidth = 1
        nameTF.layer.borderColor = UIColor.black.cgColor
        nameTF.isUserInteractionEnabled = true
        cameraButton.isHidden = false
        settingsButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
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
 
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        settingButtonClicked = !settingButtonClicked
        
        if settingButtonClicked {
            settingsForm()
        } else {
            defaultForm()
        }
        
        // alertAction 취소 눌렀을때 다시 본래대로
        aboutMeTextView.text = user?.aboutMe
        nameTF.text = user?.name
        // 카메라버튼 동작시키기
        // 완료 버튼 눌렀을때 db업데이트 시키기
        // post 삭제버튼 동작시키기(이것도 alertAciton 넣기)
        // Home페이지 구현
        
        
        collectionView.reloadData()
        
    }
    
    func fetchUserAndUpdateForm() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observe( .value) { snapshot in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            self.user = user
            
            guard let url = URL(string: user.profileImageURL) else { return }
            let imageData = NSData(contentsOf: url)
            let image = UIImage(data: imageData! as Data)
            self.collectionView.reloadData()
            self.fetchOrderedPosts()
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.aboutMeTextView.text = user.aboutMe
                self.nameTF.text = user.name
            }
        }
    }
    
    func fetchOrderedPosts() {
        guard let uid = user?.uid else { return }
        let dbRef = Database.database().reference().child("posts").child(uid)
        
        dbRef.queryOrdered(byChild: "creationDate").observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }
    }
}


//MARK: - collectionView Delegate
extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as? MyPageCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.post = posts[indexPath.item]
        
        if settingButtonClicked {
            cell.deleteButton.isHidden = false
        } else {
            cell.deleteButton.isHidden = true
        }
        
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
