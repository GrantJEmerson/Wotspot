//
//  NSLayoutConstraint+PrioritySetter.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/28/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    func withPriority(_ priority: Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(rawValue: priority)
        return self
    }
}
