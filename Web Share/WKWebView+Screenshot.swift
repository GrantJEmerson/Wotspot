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
        let rep = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: rep)
        let image: NSImage = NSImage()
        image.addRepresentation(rep)
        return image
    }
}
