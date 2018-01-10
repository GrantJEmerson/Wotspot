//
//  StatusIndicatorView.swift
//  Web Share
//
//  Created by Grant Emerson on 1/9/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

public enum ConnectionStatus {
    case notConnected, connecting, connected
}

class StatusIndicatorView: NSView {
    
    // MARK: Properties
    
    open var status: ConnectionStatus = .notConnected {
        didSet {
            switch status {
            case .notConnected:
                fillColor = NSColor.red
            case .connecting:
                fillColor = NSColor.yellow
            case .connected:
                fillColor = NSColor.green
            }
            draw(bounds)
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
