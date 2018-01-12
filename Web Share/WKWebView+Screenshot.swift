//
//  WKWebView+Screenshot.swift
//  Web Share
//
//  Created by Grant Emerson on 1/11/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit
import WebKit

extension WKWebView {
    
    var screenshot: NSImage {
        let displayID = CGWindowID() // cgmaindisplayid
        let imageRef = CGDisplayCreateImage(displayID)
        return NSImage(cgImage: imageRef!, size: (NSScreen.main?.frame.size)!)
    }
}
