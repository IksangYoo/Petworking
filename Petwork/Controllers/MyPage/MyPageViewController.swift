//
//  MyPageViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import Firebase
import FirebaseStorage

class MyPageViewController: UIViewController,UITextViewDelegate {
    
    var isSettingButtonClicked = false
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
    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MyPageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "postCell")
        fetchUserAndUpdateForm()
        defaultForm()
        imagePicker.delegate = self
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPost" {
            let destinationVC = segue.destination as! PostViewController
            destinationVC.post = post
    }
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
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: userDictionary)
                self.user = user
            }
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
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        if isSettingButtonClicked {
            confirmAlert()
        } else {
            settingAlert()
        }
    }
    
    func settingAlert() {
        let alert = UIAlertController(title: "", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Change Profile", style: .default, handler: { UIAlertAction in
            self.isSettingButtonClicked = !self.isSettingButtonClicked
            self.settingsForm()
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { UIAlertAction in
            self.signOut()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmAlert() {
        guard let currentUser = user else { return }
        let alertController = UIAlertController(title: "", message: "Confirm Changes", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { alertAction in
            self.isSettingButtonClicked = !self.isSettingButtonClicked
            let url = URL(string: currentUser.profileImageURL)
            self.aboutMeTextView.text = currentUser.aboutMe
            self.nameTF.text = currentUser.name
            self.profileImageView.kf.setImage(with: url)
            self.collectionView.reloadData()
            self.defaultForm()
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { alertAction in
            self.isSettingButtonClicked = !self.isSettingButtonClicked
            self.saveToDatabase()
            self.fetchOrderedPosts()
            self.defaultForm()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    func signOut() {
        let storyboard : UIStoryboard = UIStoryboard(name: "LoginSignUpView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
        let firebaseAuth = Auth.auth()
        
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
        print("fetchOrderedPosts")
        guard let uid = user?.uid else { return }
        let dbRef = Database.database().reference().child("posts").child(uid)
        
        posts.removeAll()
        
        dbRef.queryOrdered(byChild: "creationDate").observe( .childAdded) { snapshot in
            print("fetchOrderedPostsClosure")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            let post = Post(user: user, dictionary: dictionary)
            
            if !self.posts.contains(post) {  // 중복 막기 위해
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

        setCellForm(cell: cell)
        
        return cell
    }
    
    func setCellForm(cell: MyPageCollectionViewCell) {
        
        if isSettingButtonClicked {
            cell.xButton.isHidden = false
            cell.xButton.isEnabled = false
            cell.postImageView.alpha = 0.5
        } else {
            cell.xButton.isEnabled = false
            cell.xButton.isHidden = true
            cell.postImageView.alpha = 1
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSettingButtonClicked {
            let alert = UIAlertController(title: "", message: "Do you want to delete this post?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes, I do", style: .default, handler: { action in
                self.deletePost(indexPath)
                self.fetchOrderedPosts()
            })
            let noAction = UIAlertAction(title: "No, I don't", style: .cancel)
            alert.addAction(noAction)
            alert.addAction(yesAction)
            present(alert, animated: true)
        } else {
            post = posts[indexPath.item]
            performSegue(withIdentifier: "goToPost", sender: self)
        }
    }
                            
    func deletePost(_ indexPath: IndexPath) {
            guard let uid = self.user?.uid else { return }
            let postID = self.posts[indexPath.item].autoID
            let dbRef = Database.database().reference().child("posts").child(uid).child(postID)
            dbRef.removeValue()
            self.collectionView.reloadData()
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
