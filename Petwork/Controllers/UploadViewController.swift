//
//  UploadViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import YPImagePicker
import Firebase

class UploadViewController: UIViewController {
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var selectedImages : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        imageScrollView.delegate = self
    }
    
    func setupView() {
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        pageControl.currentPage = 0
        pageControl.numberOfPages = 2
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
    }
    
    @IBAction func selectPhotoButtonPressed(_ sender: UIButton) {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 5
        config.albumName = "Petwork"
        config.startOnScreen = YPPickerScreen.library
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            for item in items {
                switch item {
                case .photo(let photo):
                    let image = photo.image
                    self.selectedImages.append(image)
                case .video(let video):
                    print(video)
                }
            }
            self.addImagesToScrollView(images: self.selectedImages)
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true)
    }
    
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        storePostToFB(with: selectedImages)
    }
    
    func storePostToFB(with postImages: [UIImage]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let caption = captionTextView.text else { return }
        let storageRef = Storage.storage().reference().child("postImages").child(uid)
        let dbRef = Database.database().reference().child("posts").child(uid).childByAutoId()
        var urls : [String] = []
        
        postImages.enumerated().forEach { index, image in
            let filename = NSUUID().uuidString
            guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
            
            storageRef.child(filename).putData(imageData, metadata: nil) { metaData, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    storageRef.child(filename).downloadURL { url, error in
                        
                        guard let URL = url?.absoluteString else { return }
                        urls.append(URL)
                        dbRef.updateChildValues(["url": urls, "caption": caption, "creationDate": Date().timeIntervalSince1970])
                    }
                }
            }
        }
        
    }
    
}


//MARK: - UIScrollViewDelegate & pageControl
extension UploadViewController: UIScrollViewDelegate {
    
    func addImagesToScrollView(images: [UIImage]) {
        for i in 0..<images.count {
            let imageView = UIImageView()
            let xPos = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: imageScrollView.bounds.width, height: imageScrollView.bounds.height)
            imageView.image = images[i]
            imageScrollView.addSubview(imageView)
            imageScrollView.contentSize.width = imageView.frame.width * CGFloat(i + 1)
        }
        pageControl.numberOfPages = images.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))    }
    
    func setPageControl() {
        pageControl.numberOfPages = selectedImages.count
        
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
}
