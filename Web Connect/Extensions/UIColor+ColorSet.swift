//
//  UIColor+ColorSet.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/27/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let defaultButtonColor = UIColor(r: 0, g: 122, b: 255)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
