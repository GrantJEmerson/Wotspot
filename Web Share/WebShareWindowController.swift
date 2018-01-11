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
    
    private lazy var progressBar: ProgressBar = {
        let progressBar = ProgressBar()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    @IBOutlet weak var searchBar: NSTextField! {
        didSet { setUpSearchBar() }
    }
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
    
    // MARK: Private Functions
    
    private func setUpSearchBar() {
        searchBar.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension WebShareWindowController: WindowControllerDelegate {
    
    func changeConnectionStatusTo(_ status: MCSessionState) {
        statusIndicatorView.status = status
    }
    
    func setDataChartTo(_ percentage: CGFloat) {
        piChartView.percentage = percentage
    }
    
    func setLoadingPercentTo(_ percentage: Double) {
        progressBar.setProgress(percentage)
    }
}
