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
    
    public weak var webView: CustomWebView?
    
    public var drawerDelegate: WebSessionDrawerDelegate?
    
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    @available(iOS 10.0, *)
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var awaitingURL: URL?
    private var userAgent = UserAgent.mobile
    
    private lazy var peerID = MCPeerID.saved
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        return session
    }()
    
    private lazy var assistant: MCAdvertiserAssistant = {
        let assistant = MCAdvertiserAssistant(serviceType: "Web-Share", discoveryInfo: nil, session: session)
        return assistant
    }()
        
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
            //guard searchResult.webPage.url == awaitingURL else { return }
            awaitingURL = nil
            webView?.loadWebPage(searchResult.webPage)
            drawerDelegate?.updateDataUsageGraph(dataSet: searchResult.dataSet)
        } else if let command = String(data: data, encoding: .utf8) {
            switch command {
            case "disconnect":
                session.disconnect()
                presentDisconnectedAlert()
            case "Not-Found":
                webView?.loadHTMLString(WebErrorPage.notFound, baseURL: nil)
            default:
                break
            }
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
            self.webView?.loadHTMLString(WebErrorPage.offline, baseURL: nil)
        }
    }
    

}

extension UserWebSessionViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        decodeMultipeerConnectivityData(data)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard peerID.displayName == "Host",
            state == .notConnected else { return }
        presentDisconnectedAlert()
        drawerDelegate?.updateDataUsageGraph(dataSet: DataSet(0, 1))
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension UserWebSessionViewController: ContentDelegate, ParentDelegate {
    
    var currentURL: URL? { return webView?.url }
    
    func searchFor(_ url: URL) {
        let searchRequest = SearchRequest(url: url, userAgent: userAgent)
        drawerDelegate?.prepareForSearch()
        drawerDelegate?.updateBookmarkIconFor(url)
        webView?.forwardURLs.removeAll()
        sendSearchRequest(searchRequest)
        guard let currentURL = webView?.url else { return }
        webView?.backwardURLs.append(currentURL)
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
    
    func goBack() {
        guard !(webView?.backwardURLs.isEmpty ?? true),
            let previousURL = webView?.backwardURLs.removeLast() else { return }
        let searchRequest = SearchRequest(url: previousURL)
        sendSearchRequest(searchRequest)
        guard let currentURL = webView?.url else { return }
        webView?.forwardURLs.append(currentURL)
    }
    
    func goForward() {
        guard !(webView?.forwardURLs.isEmpty ?? true),
            let nextURL = webView?.forwardURLs.removeLast() else { return }
        let searchRequest = SearchRequest(url: nextURL)
        sendSearchRequest(searchRequest)
        guard let currentURL = webView?.url else { return }
        webView?.backwardURLs.append(currentURL)
    }
    
    func bookmark() {
        
        var bookmark = Bookmark()
        
        if #available(iOS 10.0, *) {
            guard let moc = moc else { return }
            bookmark = Bookmark(context: moc)
        } else {
            guard let moc = appDelegate?.managedObjectContext,
                let entityDescription = NSEntityDescription.entity(forEntityName: "Bookmark", in: moc) else { return }
            bookmark = Bookmark(entity: entityDescription, insertInto: moc)
        }
        
        bookmark.title = webView?.title
        bookmark.url = webView?.url?.absoluteString
        bookmark.screenshot = webView?.screenshot
        bookmark.date = Date()
        
        appDelegate?.saveContext()
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
}
