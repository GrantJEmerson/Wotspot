//
//  Image+ScaleToFill.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/13/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

extension NSImage {
    func scaleToFillImage(in bounds: NSRect) -> NSImage {
        return NSImage(size: size, flipped: false, drawingHandler: {(_ dstRect: NSRect) -> Bool in
            var newImageSize: NSSize = self.size
            let imageAspectRatio: CGFloat = self.size.height / self.size.width
            let imageViewAspectRatio: CGFloat = bounds.size.height / bounds.size.width
            if imageAspectRatio < imageViewAspectRatio {
                newImageSize.width = self.size.height / imageViewAspectRatio
            } else {
                newImageSize.height = self.size.width * imageViewAspectRatio
            }
            let srcRect: NSRect = NSMakeRect(self.size.width / 2.0 - newImageSize.width / 2.0, self.size.height / 2.0 - self.size.height / 2.0, newImageSize.width, newImageSize.height)
            NSGraphicsContext.current?.imageInterpolation = .high
            self.draw(in: dstRect, from: srcRect, operation: .copy, fraction: 1.0, respectFlipped: true, hints: nil)
            return true
        })
    }
}
