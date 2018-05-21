//
//  BookmarkTableViewCell.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/9/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

protocol BookmarkCellDelegate: class {
    func delete(_ cell: BookmarkTableViewCell)
}

class BookmarkTableViewCell: NSTableCellView {
    
    // MARK: Properties
    
    public weak var delegate: BookmarkCellDelegate?
    
    public var editing: Bool = false {
        didSet {
            deletionView.isHidden = !editing
        }
    }
    
    public var bookmark: Bookmark? {
        didSet {
            guard let bookmark = bookmark else { return }
            bookmarkTitleLabel.stringValue = bookmark.title ?? ""
            let screenshotImage = bookmark.screenshot as? NSImage
            bookmarkScreenshotImageView.image = screenshotImage?.scaleToFillImage(in: bookmarkScreenshotImageView.bounds)
        }
    }
    
    @IBOutlet weak var deletionView: DeletionView! {
        didSet {
            deletionView.delegate = self
        }
    }
    
    @IBOutlet weak var bookmarkTitleLabel: NSTextField!
    @IBOutlet weak var bookmarkScreenshotImageView: NSImageView! {
        didSet {
            bookmarkScreenshotImageView.imageScaling = .scaleAxesIndependently
            bookmarkScreenshotImageView.wantsLayer = true
            bookmarkScreenshotImageView.layer?.cornerRadius = 8
            bookmarkScreenshotImageView.layer?.masksToBounds = true
        }
    }
    
    // MARK: Init
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        NotificationCenter.default.addObserver(forName: .beginBookmarkEditing, object: nil, queue: .main) { (_) in
            self.deletionView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(forName: .endBookmarkEditing, object: nil, queue: .main) { (_) in
            self.deletionView.isHidden = true
        }
    }
}

extension BookmarkTableViewCell: DeletionViewDelegate {
    
    func deleteClicked() {
        delegate?.delete(self)
    }
}
