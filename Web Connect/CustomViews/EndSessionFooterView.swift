//
//  EndSessionFooterView.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/30/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class EndSessionFooterView: UIView {
    
    // MARK: Properties
    
    public weak var userManagementView: UserManagementView?
    
    private lazy var endSessionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitle("End Session", for: .normal)
        button.addTarget(self, action: #selector(endSessionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backgroundBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()
    
    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 3
        backgroundColor = .clear
        
        addSubview(backgroundBlurView)
        addSubview(endSessionButton)
        backgroundBlurView.constrainToParent()
        endSessionButton.constrainToParent()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    @objc private func endSessionButtonTapped() {
        userManagementView?.delegate?.endSession()
    }

}
