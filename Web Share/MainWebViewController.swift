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

public protocol WindowControllerDelegate: class {
    func changeConnectionStatusTo(_ status: MCSessionState)
    func setDataChartTo(_ percentage: Int)
}

class MainWebViewController: NSViewController {
    
    // MARK: Properties
    
    public weak var delegate: WindowControllerDelegate?
    
    private var bookmarks = [Bookmark]()
    
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
                        var searchButton = document.getElementById("_fZl");
                        searchButton.addEventListener("click", function() {
                            var searchText = document.getElementById("lst-ib").value;
                            window.webkit.messageHandlers.macListener.postMessage("Search: " + searchText);
                        });
                    """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        return script
    }()
    
    private lazy var configuration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(searchButtonScript)
        configuration.userContentController.add(self, name: "macListener")
        return configuration
    }()
    
    public lazy var webView: CustomWebView = {
        let webView = CustomWebView(frame: .zero, configuration: configuration)
        webView.loadHTMLString(WebErrorPage.offline, baseURL: nil)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var progressView: NSProgressIndicator = {
        let progressView = NSProgressIndicator()
        progressView.style = .spinning
        progressView.isDisplayedWhenStopped = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    
    @IBOutlet weak var bookmarkView: NSView! {
        didSet {
            setUpSubviews()
        }
    }
    
    public enum BookmarkViewPosition {
        case open, closed
    }
    
    @IBOutlet weak var bookmarkTableView: NSTableView!
    @IBOutlet weak var bookmarkViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assistant.start()
        getBookmarks()
    }
    
    // MARK: Selector Functions
    
    @objc public func bookmarkViewToggleSelected(_ sender: NSMenuItem) {
        let open = sender.title == "Hide Bookmarks"
        setBookmarkViewTo(open ? .closed : .open)
        sender.title = open ? "Show Bookmarks" : "Hide Bookmarks"
    }
    
    @objc public func addBookmark() {
        guard let currentURL = webView.url else { return }
        
        let existingBookmark = bookmarks.first { (bookmark) -> Bool in
            return bookmark.url == currentURL.absoluteString
        }
        
        if let existingBookmark = existingBookmark {
            moc?.delete(existingBookmark)
        } else {
            guard let moc = moc else { return }
            let bookmark = Bookmark(context: moc)
            bookmark.title = webView.title
            bookmark.url = webView.url?.absoluteString
            bookmark.screenshot = webView.screenshot
            bookmark.date = Date()
            
            appDelegate?.saveAction(self)
        }
        
        getBookmarks()
    }
    
    @objc public func leaveSession() {
        session.disconnect()
        delegate?.setDataChartTo(100)
        webView.loadHTMLString(WebErrorPage.offline, baseURL: nil)
    }
    
    // MARK: Public Functions
    
    public func search(_ url: URL) {
        guard session.connectedPeers.count >= 1 else { return }
        prepareForSearch()
        sendSearchRequest(SearchRequest(url: url))
        webView.forwardURLs.removeAll()
        guard let currentURL = webView.url else { return }
        webView.backwardURLs.append(currentURL)
    }
    
    public func goBack() {
        guard !webView.backwardURLs.isEmpty else { return }
        let previousURL = webView.backwardURLs.removeLast()
        let searchRequest = SearchRequest(url: previousURL)
        sendSearchRequest(searchRequest)
        guard let currentURL = webView.url else { return }
        webView.forwardURLs.append(currentURL)
    }
    
    public func goForward() {
        guard !webView.forwardURLs.isEmpty else { return }
        let nextURL = webView.forwardURLs.removeLast()
        let searchRequest = SearchRequest(url: nextURL)
        sendSearchRequest(searchRequest)
        guard let currentURL = webView.url else { return }
        webView.backwardURLs.append(currentURL)
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        view.addSubview(webView)
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: bookmarkView.trailingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
        ])
    }
    
    private func prepareForSearch() {
        progressView.startAnimation(self)
    }
    
    private func decodeMultipeerConnectivityData(_ data: Data) {
        if let searchResult = try? PropertyListDecoder().decode(SearchResult.self, from: data) {
            guard searchResult.webPage.url == awaitingURL else { return }
            awaitingURL = nil
            webView.loadWebPage(searchResult.webPage)
            updateDataUsageGraphsWith(searchResult.dataSet)
        } else if let command = String(data: data, encoding: .utf8) {
            switch command {
            case "disconnect":
                session.disconnect()
                delegate?.changeConnectionStatusTo(.notConnected)
                webView.loadHTMLString(WebErrorPage.offline, baseURL: nil)
                presentDisconnectedAlert()
            case "Not-Found":
                webView.loadHTMLString(WebErrorPage.notFound, baseURL: nil)
            default:
                break
            }
        }
        DispatchQueue.main.async {
            self.progressView.stopAnimation(self)
        }
    }
    
    private func updateDataUsageGraphsWith(_ dataSet: DataSet) {
        delegate?.setDataChartTo(dataSet.availablePercentage())
    }
    
    private func presentDisconnectedAlert() {
        let alert = NSAlert()
        alert.messageText = "Disconnected"
        alert.informativeText = "You have been removed from the current Web Share session."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func sendSearchRequest(_ searchRequest: SearchRequest) {
        guard let data = try? PropertyListEncoder().encode(searchRequest) else { return }
        do {
            guard let host = session.connectedPeers.filter({ $0.displayName == "Host" }).first else { return }
            awaitingURL = searchRequest.url
            try session.send(data, toPeers: [host], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getBookmarks() {
        
        let fetchRequest = Bookmark.fetchRequest() as NSFetchRequest<Bookmark>
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            guard let bookmarks = try moc?.fetch(fetchRequest) else { return }
            self.bookmarks = bookmarks
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.bookmarkTableView.reloadData()
        }
    }
    
    private func setBookmarkViewTo(_ position: BookmarkViewPosition) {
        let newConstraintConstant: CGFloat = position == .closed ? 0 : 200
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            bookmarkViewTrailingConstraint.animator().constant = newConstraintConstant
        })
    }
    
}

extension MainWebViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bookmarks.count
    }
}

extension MainWebViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = bookmarkTableView.selectedRow
        guard selectedRow >= 0 else { return }
        guard let url = URL(string: bookmarks[selectedRow].url!) else { return }
        search(url)
        bookmarkTableView.deselectRow(selectedRow)
    }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = bookmarkTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "bookmarkCellID"), owner: self) as? BookmarkTableViewCell
        cell?.bookmark = bookmarks[row]
        return cell
    }
}

extension MainWebViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        decodeMultipeerConnectivityData(data)
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        delegate?.changeConnectionStatusTo(.connected)
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MainWebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let message = message.body as? String,
            message.hasPrefix("Search: ") else { return }
        let search = message.replacingOccurrences(of: "Search: ", with: "")
        guard let url = URL(search: search) else { return }
        sendSearchRequest(SearchRequest(url: url))
    }
}
