//
//  ProgressBar.swift
//  Web Share
//
//  Created by Grant Emerson on 1/11/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class ProgressBar: NSView {
    
    // MARK: Properties
    
    private lazy var blueIndicatorBar: NSView = {
        let view = NSView()
        view.layer?.cornerRadius = 5
        view.layer?.backgroundColor = NSColor(red: 0, green: 112, blue: 255, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var blueIndicatorBarWidth: NSLayoutConstraint!
    
    // MARK: Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpSubviews()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        addSubview(blueIndicatorBar)
        
        blueIndicatorBarWidth = blueIndicatorBar.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            blueIndicatorBar.topAnchor.constraint(equalTo: topAnchor),
            blueIndicatorBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            blueIndicatorBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            blueIndicatorBarWidth
        ])
    }
    
    // MARK: Open Functions
    
    open func setProgress(_ value: Double) {
        blueIndicatorBarWidth.constant = value != 0 ? CGFloat(value) * bounds.width : 0
        setNeedsDisplay(bounds)
    }
    
}
