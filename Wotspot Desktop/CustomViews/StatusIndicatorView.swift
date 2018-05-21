//
//  StatusIndicatorView.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/9/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit
import MultipeerConnectivity

class StatusIndicatorView: NSView {
    
    // MARK: Properties
    
    open var status: MCSessionState = .notConnected {
        didSet {
            switch status {
            case .notConnected:
                fillColor = NSColor.red
            case .connecting:
                fillColor = NSColor.yellow
            case .connected:
                fillColor = NSColor.green
            }
            DispatchQueue.main.async {
                self.needsDisplay = true
            }
        }
    }
    
    private var fillColor = NSColor.red
    
    // MARK: Draw
    
    override func draw(_ dirtyRect: NSRect) {
        let ovalPath = NSBezierPath(ovalIn: dirtyRect)
        fillColor.setFill()
        ovalPath.fill()
    }
}
