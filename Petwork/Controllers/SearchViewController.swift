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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
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
                self.users.append(user)
            }
            self.users.sort { user1, user2 in
                return user1.name.compare(user2.name) == .orderedAscending
            }
            self.filteredUsers = self.users
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        if let title = sender.currentTitle {
            searchterm = title
            performSegue(withIdentifier: "goToResults", sender: self)
        }
        
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
