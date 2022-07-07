//
//  CustomImageView.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/07/06.
//

import UIKit

// image caching
var imageCache = [String: UIImage]()

var j = 0


class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        self.image = nil
        lastURLUsedToLoadImage = urlString
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        j += 1
        print("Cache Miss: \(j)")
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print("Failed to fetch post image:", e)
                return
            }
            // because of reusing cell
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }

}

