//
//  UploadViewController.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/25.
//

import UIKit
import YPImagePicker

class UploadViewController: UIViewController {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func selectPhotoButtonPressed(_ sender: UIButton) {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 5
        config.albumName = "Petwork"
        config.startOnScreen = YPPickerScreen.library
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { items, cancelled in
            for item in items {
                    switch item {
                    case .photo(let photo):
                        print(photo.url)
                        print(photo)
                    case .video(let video):
                        print(video)
                    }
                }
                picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true)
    }

}

