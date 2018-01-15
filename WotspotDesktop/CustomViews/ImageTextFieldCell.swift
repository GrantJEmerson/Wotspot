//
//  ImageTextFieldCell.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/12/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class ImageTextFieldCell: NSTextFieldCell {
    
    // MARK: Properties
    
    private let detailImage = #imageLiteral(resourceName: "SearchIcon")
    
    private lazy var imageView: NSImageView = {
        let imageView = NSImageView(image: detailImage)
        imageView.imageAlignment = .alignCenter
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Init
    
    override init(textCell string: String) {
        super.init(textCell: string)
        setUpImageView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpImageView()
    }
    
    // MARK: Draw
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let leftPadding = imageView.bounds.width - 3
        let rectInset = NSMakeRect(rect.origin.x + leftPadding, rect.origin.y, rect.size.width - leftPadding, rect.size.height)
        return super.drawingRect(forBounds: rectInset)
    }
    
    // MARK: Private Function
    
    private func setUpImageView() {
        
        guard let controlView = controlView else { return }
        controlView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: controlView.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: controlView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 14)
        ])
    }
    
}

