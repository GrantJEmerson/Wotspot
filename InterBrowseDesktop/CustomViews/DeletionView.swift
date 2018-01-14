//
//  DeletionView.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/13/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

public protocol DeletionViewDelegate: class {
    func deleteClicked()
}

class DeletionView: NSView {
    
    // MARK: Properties
    
    public weak var delegate: DeletionViewDelegate?
    
    private lazy var deleteButton: NSButton = {
        let button = NSButton(image: #imageLiteral(resourceName: "DeleteButtonIcon"), target: self, action: #selector(deleteButtonClicked))
        button.isTransparent = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpSubviews()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setUpSubviews()
    }
    
    // MARK: Selector Functions
    
    @objc private func deleteButtonClicked() {
        delegate?.deleteClicked()
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 60),
            deleteButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
