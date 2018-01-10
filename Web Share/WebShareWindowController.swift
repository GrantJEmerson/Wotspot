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
    
    var mainWebViewController: MainWebViewController! {
        return contentViewController as? MainWebViewController
    }
    @IBOutlet weak var searchBar: NSTextField!
    @IBOutlet weak var piChartView: PiChartView!
    @IBOutlet weak var statusIndicatorView: StatusIndicatorView!
    
    // MARK: IBActions
    
    @IBAction func backButtonClicked(_ sender: NSButton) {
        mainWebViewController.goBack()
    }
    
    @IBAction func forwardButtonClicked(_ sender: NSButton) {
        mainWebViewController.goForward()
    }
    
    @IBAction func searchBarDidEnter(_ sender: NSTextField) {
        guard let search = searchBar.stringValue.nilIfEmpty(),
            let url = URL(search: search) else { return }
        mainWebViewController.search(url)
    }
}
