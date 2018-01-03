//
//  SeperatorView.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/27/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class SeperatorView: UIView {
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    // MARK: Private Functions
    
    private func setUpView() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 1.5).isActive = true
    }
}

