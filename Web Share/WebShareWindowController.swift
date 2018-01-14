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
    
    private lazy var mainWebViewController: MainWebViewController = {
        return contentViewController as! MainWebViewController
    }()

    @IBOutlet weak var searchBar: NSTextField!
    @IBOutlet weak var piChartView: PiChartView!
    @IBOutlet weak var statusIndicatorView: StatusIndicatorView!
    
    // MARK: Window Life Cycle
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        mainWebViewController.delegate = self
        
        if UserDefaults.useDarkMode {
            window?.appearance = NSAppearance(named: .vibrantDark)
        }
        
        NotificationCenter.default.addObserver(forName: .appearanceChanged, object: nil, queue: .main) { (_) in
            self.window?.appearance = UserDefaults.useDarkMode ? NSAppearance(named: .vibrantDark) : NSAppearance(named: .vibrantLight)
        }
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
