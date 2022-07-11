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
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    
    var user: User?
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MyPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "postCell")
        fetchUserAndUpdateForm()
        fetchOrderedPosts()

        defaultForm()
        imagePicker.delegate = self
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
    
    func deleteStroageImage() {
        guard let uid = user?.uid else { return }
        Storage.storage().reference().child("userProfileImages").child(uid).delete { error in
            if let e = error {
                print(e.localizedDescription)
            } else {
                print("Successfully deleted")
            }
        }
    }
    
    func saveToDatabase() {
        deleteStroageImage()
        
        guard let image = profileImageView.image else { return }
        guard let name = nameTF.text else { return }
        guard let aboutMe = aboutMeTextView.text else { return }
        guard let uid = user?.uid else { return }
        
    
        Storage.storage().uploadUserProfileImage(profileImage: image, uid: uid) { profileImageURL, error in
            if let e = error {
                print(e.localizedDescription)
            } else {
                let dbRef = Database.database().reference().child("users").child(uid)
                
                dbRef.updateChildValues(["name": name, "profileImageURL": profileImageURL!, "aboutMe": aboutMe]) { error, ref in
                    }
                }
            Database.database().reference().child("users").child(uid).observe( .value) { snapshot in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: userDictionary)
                self.user = user
                print(user)
            }
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        settingButtonClicked = !settingButtonClicked
        
        if settingButtonClicked {
            settingsForm()
        } else {
            defaultForm()
            saveToDatabase()
            fetchOrderedPosts()
        }
        
        // alertAction 취소 눌렀을때 다시 본래대로
        aboutMeTextView.text = user?.aboutMe
        nameTF.text = user?.name
        
        // 완료 버튼 눌렀을때 db업데이트 시키기, user dic 업데이트
        // post 삭제버튼 동작시키기(이것도 alertAciton 넣기)
        // Home페이지 구현
    }
    
    func fetchUserAndUpdateForm() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dbref = Database.database().reference().child("users").child(uid)
        
        dbref.observe( .value) { snapshot in
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
            
            if !self.posts.contains(post) {
                self.posts.insert(post, at: 0)
            }
            
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

//MARK: - UIPickerController
extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func changeProfileImagePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { UIAlertAction in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [self] UIAlertAction in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
}
