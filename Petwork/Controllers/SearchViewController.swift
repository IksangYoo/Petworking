//
//  SearchViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import Firebase
import Kingfisher

class SearchViewController: UIViewController {
    var searchterm: String = ""
    var users = [User]()
    var user : User?
    var filteredUsers = [User]()
    var currentUser : User?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveCurrentUser()
        fetchUsers()
        setButtonsUI()
        searchBar.searchTextField.textColor = .black
    }
    
    func setButtonsUI() {
        for i in 0..<buttons.count {
            buttons[i].layer.cornerRadius = 20
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
    
    
    func fetchUsers() {
        let dbRef = Database.database().reference().child("users")
        
        dbRef.observeSingleEvent(of: .value) { snapshot in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { uid, value in
                if uid == Auth.auth().currentUser?.uid {
                    return
                }
                guard let userDict = value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: userDict)
                
                if self.currentUser?.blockedUser == nil {
                    self.users.append(user)
                } else if !self.currentUser!.blockedUser.contains(user.uid) {
                    self.users.append(user)
                }
            }
            self.users.sort { user1, user2 in
                return user1.name.compare(user2.name) == .orderedAscending
            }
            self.filteredUsers = self.users
            self.collectionView.reloadData()
        }
    }

    @IBAction func tagsPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        searchterm = title
        performSegue(withIdentifier: "goToResults", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResults" {
            let destinationVC = segue.destination as! ResultsViewController
            destinationVC.searchTag = searchterm
        } else if segue.identifier == "goToUser" {
            let destinationVC = segue.destination as! UserViewController
            destinationVC.user = user
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { (user) -> Bool in
                return user.name.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? searchUserCell
        else { return UICollectionViewCell() }
        cell.user = filteredUsers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        user = filteredUsers[indexPath.item]
        performSegue(withIdentifier: "goToUser", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }

}

class searchUserCell: UICollectionViewCell {
    var user: User? {
        didSet {
            nameLabel.text = user?.name
            guard let profileImageUrl = user?.profileImageURL else { return }
            let url = URL(string: profileImageUrl)
            profileImageView.kf.setImage(with: url)
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: CircularImageView!
}
