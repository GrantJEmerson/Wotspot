//
//  BookmarkTableViewCell.swift
//  Web Share
//
//  Created by Grant Emerson on 1/9/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class BookmarkTableViewCell: NSTableCellView {
    
    public var bookmark: Bookmark? {
        didSet {
            guard let bookmark = bookmark else { return }
            bookmarkTitleLabel.stringValue = bookmark.title ?? ""
            bookmarkScreenshotImageView.image = bookmark.screenshot as? NSImage
        }
    }
    
    @IBOutlet weak var bookmarkTitleLabel: NSTextField!
    @IBOutlet weak var bookmarkScreenshotImageView: NSImageView! {
        didSet {
            bookmarkScreenshotImageView.layer?.cornerRadius = 15
        }
    }
}
