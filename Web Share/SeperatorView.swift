//
//  SeperatorView.swift
//  Web Share
//
//  Created by Grant Emerson on 1/13/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class SeperatorView: NSView {
    
    // MARK: Properties
    
    private var color: NSColor = .darkGray
    
    // MARK: Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpView()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setUpView()
    }
    
    // MARK: Draw
    
    override func draw(_ dirtyRect: NSRect) {
        let background = NSBezierPath(rect: dirtyRect)
        color.setFill()
        background.fill()
    }
    
    // MARK: Private Functions
    
    private func setUpView() {
        
        if UserDefaults.useDarkMode {
            color = .lightGray
        }
        
        NotificationCenter.default.addObserver(forName: .appearanceChanged, object: nil, queue: .main) { (_) in
            self.color = UserDefaults.useDarkMode ? .lightGray : .darkGray
            self.needsDisplay = true
        }
    }
}
