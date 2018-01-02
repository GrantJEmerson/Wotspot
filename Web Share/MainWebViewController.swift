//
//  MainWebViewController.swift
//  Web Share
//
//  Created by Grant Emerson on 1/2/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit
import MultipeerConnectivity
import CoreData
import WebKit

class MainWebViewController: NSViewController {
    
    // MARK: Properties
    
    private lazy var appDelegate = NSApplication.shared.delegate as? AppDelegate
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var awaitingURL: URL?
    
    // Multipeer Connectivity
    
    private lazy var peerID = MCPeerID.saved
    
    private lazy var assistant: MCAdvertiserAssistant = {
        let assistant = MCAdvertiserAssistant(serviceType: "Web-Share", discoveryInfo: nil, session: session)
        return assistant
    }()
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: peerID)
        session.delegate = self
        return session
    }()
    
    // WKWebView Set Up
    
    private lazy var searchButtonScript: WKUserScript = {
        let source = """
                        var searchButton = document.getElementById("tsbb");
                        searchButton.addEventListener("click", function() {
                            var searchText = document.getElementById("lst-ib").value;
                            window.webkit.messageHandlers.iosListener.postMessage("Search: " + searchText);
                        });
                    """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        return script
    }()
    
    private lazy var configuration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(searchButtonScript)
        configuration.userContentController.add(self, name: "iosListener")
        return configuration
    }()
    
    public lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assistant.start()
    }
    
    override func viewWillAppear() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewWillDisappear() {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "estimatedProgress" else { return }
        //TODO: Update progressview with webview.estimatedprogress
    }
    
    // MARK: Private Functions
    
    private func decodeMultipeerConnectivityData(_ data: Data) {
        if let searchResult = try? PropertyListDecoder().decode(SearchResult.self, from: data) {
            guard searchResult.webPage.url == awaitingURL else { return }
            awaitingURL = nil
            webView.loadWebPage(searchResult.webPage)
            // TODO: Update Data Usage Graph
        } else if let disconnectMessage = String(data: data, encoding: .utf8) {
            guard disconnectMessage == "disconnect" else { return }
            session.disconnect()
            presentDisconnectedAlert()
        }
    }
    
    private func sendSearchRequest(_ searchRequest: SearchRequest) {
        guard let data = try? PropertyListEncoder().encode(searchRequest) else { return }
        do {
            let host = session.connectedPeers.filter({ $0.displayName == "Host" })
            awaitingURL = searchRequest.url
            try session.send(data, toPeers: host, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func presentDisconnectedAlert() {
        // TODO: Change connected status
    }
    
}

extension MainWebViewController: MCSessionDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismissViewController(browserViewController)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismissViewController(browserViewController)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        decodeMultipeerConnectivityData(data)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MainWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let message = message.body as? String,
            message.hasPrefix("Search: ") else { return }
        let search = message.replacingOccurrences(of: "Search: ", with: "")
        guard let url = URL(search: search) else { return }
        // Search for url
    }
}

