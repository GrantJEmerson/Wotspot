//
//  SeperatorView.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/13/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class SeperatorView: NSView {
    
    // MARK: Properties
    
    private var color: NSColor = UserDefaults.useDarkMode ? .lightGray : .darkGray
    
    // MARK: Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUpObserver()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setUpObserver()
    }
    
    // MARK: Draw
    
    override func draw(_ dirtyRect: NSRect) {
        let background = NSBezierPath(rect: dirtyRect)
        color.setFill()
        background.fill()
    }
    
    // MARK: Private Functions
    
    private func setUpObserver() {
        NotificationCenter.default.addObserver(forName: .appearanceChanged, object: nil, queue: .main) { (_) in
            self.color = UserDefaults.useDarkMode ? .lightGray : .darkGray
            self.needsDisplay = true
        }
    }
}
