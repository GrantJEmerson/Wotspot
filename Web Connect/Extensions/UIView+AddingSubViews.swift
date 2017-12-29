//
//  UIView+AddingSubViews.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/28/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach({ addSubview($0) })
    }
}
