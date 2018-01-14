//
//  UIButton+SwitchImage.swift
//  InterBrowse
//
//  Created by Grant Emerson on 12/19/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

typealias ImageSet = (image1: UIImage, image2: UIImage)

extension UIButton {
    
    func switchImage(imageSet: ImageSet, transition: UIViewAnimationOptions) {
        let currentImage = self.image(for: .normal)
        let newImage = (currentImage == imageSet.image1) ? imageSet.image2 : imageSet.image1
        
        UIView.transition(with: imageView!, duration: 0.8, options: transition, animations: {
            self.setImage(newImage, for: .normal)
        })
    }
}
