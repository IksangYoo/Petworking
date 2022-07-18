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
    @IBOutlet weak var uploadButton: UIButton!
    var selectedImages : [UIImage] = []
    var num = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        imageScrollView.delegate = self
    }
    
    func setupView() {
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.layer.borderWidth = 1
        imageScrollView.layer.borderColor = #colorLiteral(red: 1, green: 0.6020463109, blue: 0.6233303547, alpha: 1)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 2
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        captionTextView.text = "Caption..."
        captionTextView.textColor = UIColor.lightGray
    }
    
    @IBAction func selectPhotoButtonPressed(_ sender: UIButton) {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 5
        config.albumName = "Petwork"
        config.startOnScreen = YPPickerScreen.library
//        config.colors.filterBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
//        config.colors.selectionsBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
//        config.colors.safeAreaBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
//        config.colors.assetViewBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
//        config.colors.libraryScreenBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
//        config.colors.bottomMenuItemBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
//        config.colors.photoVideoScreenBackgroundColor = #colorLiteral(red: 0.9981967807, green: 0.963527143, blue: 0.9382537007, alpha: 1)
        
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
            self.imageScrollView.layer.borderColor = UIColor.black.cgColor
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true)
    }
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        selectedImages.removeAll()
        removeSubviews()
        setupView()
    }
    
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        
        if selectedImages.isEmpty {
            let alert = UIAlertController(title: "Upload Failed", message: "Please select a photo", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
        } else {
            storePostToFB(with: selectedImages)
            self.selectedImages.removeAll()
            let alert = UIAlertController(title: nil, message: "Post has been Successfully Uploaded!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                DispatchQueue.main.async {
                    self.removeSubviews()
                    self.setupView()
                }
                
            }
            alert.addAction(action)
            present(alert, animated: true)
        }

        
    }
    

    
    func storePostToFB(with postImages: [UIImage]) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let caption = captionTextView.text else { return }
        let storageRef = Storage.storage().reference().child("postImages").child(uid)
        let dbRef = Database.database().reference().child("posts").child(uid).childByAutoId()
        guard let autoID = dbRef.key else { return }
        var urls : [String] = []
        
        var urlDicWithIndex : [Int: String] = [:]
        
        for (index, image) in postImages.enumerated() {
            let filename = NSUUID().uuidString
            guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
            
            storageRef.child(filename).putData(imageData, metadata: nil) { metaData, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    storageRef.child(filename).downloadURL { url, error in
                        
                        guard let URL = url?.absoluteString else { return }
                        urlDicWithIndex[index] = URL
                        
                        let sortedDic = urlDicWithIndex.sorted(by: < )
                        
                        urls.removeAll()
                        for i in 0..<sortedDic.count {
                            urls.append(sortedDic[i].value)
                        }
                        
                        dbRef.updateChildValues(["postImageURLs": urls, "caption": caption, "autoID": autoID, "creationDate": Date().timeIntervalSince1970])
                    }
                }
            }
            
        }
       
//        postImages.enumerated().forEach { index, image in
//            let filename = NSUUID().uuidString
//
//            guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
//
//            storageRef.child(filename).putData(imageData, metadata: nil) { metaData, error in
//                if let e = error {
//                    print(e.localizedDescription)
//                } else {
//                    storageRef.child(filename).downloadURL { url, error in
//
//                        guard let URL = url?.absoluteString else { return }
//                        urls.insert(URL + "+ \(index)", at: 0)
//                        dbRef.updateChildValues(["url": urls, "caption": caption, "creationDate": Date().timeIntervalSince1970])
//                    }
//                    print("---------->urls: \(urls)")
//                }
//            }
//        }

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
    
    func removeSubviews() {
        imageScrollView.subviews.forEach({ $0.removeFromSuperview() })
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    
    func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
}

//MARK: - UITextViewDelegate
extension UploadViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Caption..."
            textView.textColor = UIColor.lightGray
        }
    }
}
