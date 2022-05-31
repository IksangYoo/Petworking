//
//  CircularImageView.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/31.
//

import UIKit

@IBDesignable
class CircularImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }

}
