//
//  DeletionView.swift
//  Wotspot
//
//  Created by Grant Emerson on 12/22/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

protocol DeleteViewDelegate: class {
    func deleteButtonTapped()
}

class DeletionView: UIView {
    
    // MARK: Properties
    
    public weak var delegate: DeleteViewDelegate?

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "DeleteButtonIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 50),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selector Functions

    @objc private func deleteButtonTapped() {
        delegate?.deleteButtonTapped()
    }
    
}
