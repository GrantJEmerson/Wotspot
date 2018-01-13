//
//  WebShareWindowController.swift
//  Web Share
//
//  Created by Grant Emerson on 1/8/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit
import MultipeerConnectivity

class WebShareWindowController: NSWindowController, NSWindowDelegate  {
    
    // MARK: Properties
    
    var mainWebViewController: MainWebViewController! {
        let vc = contentViewController as? MainWebViewController
        vc?.delegate = self
        return vc
    }

    @IBOutlet weak var searchBar: NSTextField!
    @IBOutlet weak var piChartView: PiChartView!
    @IBOutlet weak var statusIndicatorView: StatusIndicatorView!
    
    // MARK: Window Life Cycle
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //window?.backgroundColor = .black
    }
    
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

extension WebShareWindowController: WindowControllerDelegate {
    
    func changeConnectionStatusTo(_ status: MCSessionState) {
        statusIndicatorView.status = status
    }
    
    func setDataChartTo(_ percentage: Int) {
        piChartView.percentage = percentage
    }
}

extension WebShareWindowController: NSUserInterfaceValidations {
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if let action = item.action {
            
        }
        return true
    }
        
    @IBAction func toggleBookmarkVisibility(_ sender: AnyObject!) {
        guard let menuItem = sender as? NSMenuItem else { return }
        mainWebViewController.bookmarkViewToggleSelected(menuItem)
    }
    
    @IBAction func addBookmark(_ sender: AnyObject!) {
        mainWebViewController.addBookmark()
    }
    
    @IBAction func leaveSession(_ sender: AnyObject!) {
        mainWebViewController.leaveSession()
    }
}
