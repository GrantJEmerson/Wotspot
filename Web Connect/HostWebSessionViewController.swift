//
//  HostWebSessionViewController.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import WebKit

class HostWebSessionViewController: PulleyViewController {
    
    // MARK: Properties
    
    public weak var webView: WKWebView?
    
    public var drawerDelegate: WebSessionDrawerDelegate?
    
    private var users = [User]()
    
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var userAgent = UserAgent.mobile
        
    private let serviceType = "Web-Share"
    private let getUrlAtDocumentStartScript = "GetUrlAtDocumentStart"
    private let getUrlAtDocumentEndScript = "GetUrlAtDocumentEnd"

    private lazy var browser: MCBrowserViewController = {
        let browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self
        return browser
    }()
    
    private lazy var assistant: MCAdvertiserAssistant = {
        let assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        return assistant
    }()
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: peerID)
        session.delegate = self
        return session
    }()
    
    private lazy var peerID: MCPeerID = {
        let peerID = MCPeerID(displayName: "Host")
        return peerID
    }()
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assistant.start()
    }
    
    // MARK: Private Functions
    
    private func getSearchResult(forSearchRequest searchRequest: SearchRequest,
                              completion: @escaping (WebPage?) -> ()) {
        var urlRequest = URLRequest(url: searchRequest.url)
        urlRequest.addValue(searchRequest.userAgent.rawValue, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return }
            let responseMimeType = response?.mimeType ?? ""
            let responseBaseURL = response?.url ?? URL(string: "https://www.google.com")!
            let responseCharacterEncoding = response?.textEncodingName ?? String.Encoding.utf8.description
            let webPage = WebPage(data: data,
                                  url: responseBaseURL,
                                  mimeType: responseMimeType,
                                  textEncoding: responseCharacterEncoding)
            completion(webPage)
        }).resume()
    }
    
    private func sendSearchResult(_ searchResult: SearchResult, toPeer peer: MCPeerID) {
        
        guard let data = try? PropertyListEncoder().encode(searchResult) else { return }
        do {
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }

}

extension HostWebSessionViewController: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}

extension HostWebSessionViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let searchRequest = try? PropertyListDecoder().decode(SearchRequest.self, from: data) else { return }
        getSearchResult(forSearchRequest: searchRequest) { (webPage) in
            guard let webPage = webPage,
                let userIndex = self.users.index(where: { (user) -> Bool in
                    return user.peerID == peerID
                }) else { return }
            self.users[userIndex].dataSet.dataUsed += CGFloat(webPage.data.count)
            let searchResult = SearchResult(webPage: webPage, dataSet: self.users[userIndex].dataSet)
            self.sendSearchResult(searchResult, toPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard peerID.displayName != "Host" else { return }
        let alertController = UIAlertController(title: "Data Cap",
                                                message: "How many MB of data would you like to provide your new user?",
                                                preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Data Cap"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let textFieldText = alertController.textFields?.first!.text else {
                self.users.append(User(peerID: peerID, dataSet: DataSet())); return }
            self.users[self.users.count - 1].dataSet.dataCap = Byte(Int(textFieldText)!)
        })
        present(alertController, animated: true)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension HostWebSessionViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 3
    }
}

extension HostWebSessionViewController: ContentDelegate, ParentDelegate {
    
    var currentURL: URL? {
        return webView?.url
    }
    
    func searchFor(_ url: URL) {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(userAgent.rawValue, forHTTPHeaderField: "User-Agent")
        webView?.load(urlRequest)
        drawerDelegate?.updateBookmarkIconFor(url)
    }
    
    func reload() {
        webView?.reload()
    }
    
    func bookmark() {
        
        guard let moc = moc else { return }
        
        let bookmark = Bookmark(context: moc)
        
        bookmark.title = webView?.title
        bookmark.url = webView?.url?.absoluteString
        bookmark.screenshot = webView?.screenshot
        bookmark.date = Date()
        
        appDelegate?.saveContext()
    }
    
    func addUsers() {
        self.present(browser, animated: true)
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


