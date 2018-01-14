//
//  UIColor+ColorSet.swift
//  InterBrowse
//
//  Created by Grant Emerson on 12/27/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let themeColor = UIColor(82, 157, 193)
    static let defaultButtonColor = UIColor(0, 122, 255)
    static let deleteColor = UIColor(249, 61, 61)
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
