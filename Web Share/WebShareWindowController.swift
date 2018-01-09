//
//  WebShareWindowController.swift
//  Web Share
//
//  Created by Grant Emerson on 1/8/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class WebShareWindowController: NSWindowController, NSWindowDelegate  {
    
    // MARK: Properties
    
    var mainWebViewController: MainWebViewController! { return contentViewController as? MainWebViewController }
    
    @IBOutlet weak var searchBar: NSSearchField!
     
    // MARK: IBActions
    
    @IBAction func backButtonClicked(_ sender: NSButton) {
    }
    
    @IBAction func forwardButtonClicked(_ sender: NSButton) {
    }
    
    @IBAction func searchBarDidEnter(_ sender: NSSearchField) {
        guard let search = sender.stringValue.nilIfEmpty(),
            let url = URL(search: search) else { return }
        mainWebViewController.search(url)
    }
}
