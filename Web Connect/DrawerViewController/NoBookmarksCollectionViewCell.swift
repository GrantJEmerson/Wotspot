//
//  NoBookmarksCollectionViewCell.swift
//  InterBrowse
//
//  Created by Grant Emerson on 12/30/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class NoBookmarksCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    private lazy var noBookmarksLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.text = "No Bookmarks Available"
        label.textColor = .white
        label.numberOfLines = 2
        label.backgroundColor = .clear
        label.font = UIFont(name: "Futura", size: 100)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        clipsToBounds = true
        layer.cornerRadius = 5
        
        addSubview(noBookmarksLabel)
        
        NSLayoutConstraint.activate([
            noBookmarksLabel.topAnchor.constraint(equalTo: topAnchor),
            noBookmarksLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            noBookmarksLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).withPriority(999),
            noBookmarksLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).withPriority(999)
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
