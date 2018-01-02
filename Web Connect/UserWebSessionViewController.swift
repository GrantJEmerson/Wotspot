//
//  UserWebSessionViewController.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreData
import WebKit

class UserWebSessionViewController: PulleyViewController {
    
    // MARK: Properties
    
    public weak var webView: WKWebView?
    
    public var drawerDelegate: WebSessionDrawerDelegate?
        
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var awaitingURL: URL?
    private var userAgent = UserAgent.mobile
    
    private lazy var assistant: MCAdvertiserAssistant = {
        let assistant = MCAdvertiserAssistant(serviceType: "Web-Share", discoveryInfo: nil, session: session)
        return assistant
    }()
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: peerID)
        session.delegate = self
        return session
    }()
    
    private lazy var peerID = MCPeerID.saved
        
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assistant.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "estimatedProgress" else { return }
        guard let estimatedProgress = webView?.estimatedProgress else { return }
        drawerDelegate?.setProgressBarTo(Float(estimatedProgress))
    }
    
    // MARK: Private Functions
    
    private func decodeMultipeerConnectivityData(_ data: Data) {
        if let searchResult = try? PropertyListDecoder().decode(SearchResult.self, from: data) {
            guard searchResult.webPage.url == awaitingURL else { return }
            awaitingURL = nil
            webView?.loadWebPage(searchResult.webPage)
            drawerDelegate?.updateDataUsageGraph(dataSet: searchResult.dataSet)
        } else if let disconnectMessage = String(data: data, encoding: .utf8) {
            guard disconnectMessage == "disconnect" else { return }
            session.disconnect()
            presentDisconnectedAlert()
        }
    }
    
    private func sendSearchRequest(_ searchRequest: SearchRequest) {
        guard let data = try? PropertyListEncoder().encode(searchRequest) else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        do {
            let host = session.connectedPeers.filter({ $0.displayName == "Host" })
            awaitingURL = searchRequest.url
            try session.send(data, toPeers: host, with: .reliable)
        } catch {
            print(error.localizedDescription)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func presentDisconnectedAlert() {
        let alertController = UIAlertController(title: "Disconnected",
                                      message: "You have been removed from the current Web Share session.",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

extension UserWebSessionViewController: MCSessionDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        decodeMultipeerConnectivityData(data)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard peerID.displayName == "Host",
            state == .notConnected else { return }
        presentDisconnectedAlert()
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension UserWebSessionViewController: ContentDelegate, ParentDelegate {
    
    var currentURL: URL? { return webView?.url }
    
    func searchFor(_ url: URL) {
        let searchRequest = SearchRequest(url: url, userAgent: userAgent)
        sendSearchRequest(searchRequest)
        drawerDelegate?.updateBookmarkIconFor(url)
    }
    
    func reload() {
        guard let currentUrl = webView?.url else { return }
        let searchRequest = SearchRequest(url: currentUrl, userAgent: userAgent)
        sendSearchRequest(searchRequest)
    }
    
    func cancel() {
        awaitingURL = nil
        webView?.stopLoading()
    }
    
    func bookmark() {
        
        guard let moc = moc else { return }
        
        let bookmark = Bookmark(context: moc)
        
        bookmark.title = title
        bookmark.url = webView?.url?.absoluteString
        bookmark.screenshot = webView?.screenshot
        bookmark.date = Date()
        
        appDelegate?.saveContext()
    }
    
    func switchUserAgent() {
        userAgent = (userAgent == .mobile) ? .desktop : .mobile
    }
    
    func switchBlurEffectStyle() {
        drawerBackgroundVisualEffectView?.switchBlurEffectStyle()
    }
    
    func setPulleyPosition(_ pulleyPosition: Int) {
        setDrawerPosition(position: PulleyPosition(rawValue: pulleyPosition)!)
        guard pulleyPosition == 0 else { return }
        drawerDelegate?.endEditing()
    }
    
    func leaveSession() {
        session.disconnect()
        assistant.stop()
        dismiss(animated: true)
    }
    
    func setPeerIDTo(_ displayName: String) {
        peerID = MCPeerID(displayName: displayName)
        UserDefaults.standard.set(displayName, forKey: "displayName")
    }
    
}
