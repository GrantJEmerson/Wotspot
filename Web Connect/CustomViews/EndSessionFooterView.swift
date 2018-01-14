//
//  EndSessionFooterView.swift
//  InterBrowse
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
    
    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selector Functions
    
    @objc private func endSessionButtonTapped() {
        userManagementView?.delegate?.endSession()
    }
    
    // MARK: Private Functions
    
    private func setUpView() {
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 3
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        addSubview(endSessionButton)
        endSessionButton.constrainToParent()
    }
}
