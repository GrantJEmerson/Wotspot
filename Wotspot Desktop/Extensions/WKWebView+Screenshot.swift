//
//  WKWebView+Screenshot.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/11/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit
import WebKit

extension WKWebView {
    var screenshot: NSImage? {
        guard let window = window else { return nil }
        let imageRef = CGDisplayCreateImage(CGMainDisplayID(), rect: window.frame)
        return NSImage(cgImage: imageRef!, size: window.frame.size)
    }
}
