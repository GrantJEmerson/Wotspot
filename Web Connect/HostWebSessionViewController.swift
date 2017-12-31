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
    
    private var peerIDsToAdd = [MCPeerID]()
    
    private var users = [User]() {
        didSet {
            drawerDelegate?.updateUsers(users)
        }
    }
    
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
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { completion(nil); return }
            let responseMimeType = response?.mimeType ?? ""
            let responseBaseURL = response?.url ?? URL(string: "https://www.google.com")!
            let responseCharacterEncoding = response?.textEncodingName ?? String.Encoding.utf8.description
            let webPage = WebPage(data: data,
                                  url: responseBaseURL,
                                  mimeType: responseMimeType,
                                  textEncoding: responseCharacterEncoding)
            completion(webPage)
        }.resume()
    }
    
    private func sendSearchResult(_ searchResult: SearchResult, toPeer peer: MCPeerID) {
        
        guard let data = try? PropertyListEncoder().encode(searchResult) else { return }
        do {
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getDataAmountToAdd(to name: String, completion: @escaping (Byte?) -> ()) {
        
        let alertController = UIAlertController(title: "Add Data",
                                                message: "How many MB of data would you like to add to \(name)?",
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Data to Add"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            let textFieldText = alertController.textFields?.first!.text?.nilIfEmpty() ?? "0"
            let bytes = Byte(Int(textFieldText)! * 1000000)
            completion(bytes)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(nil)
        })
        
        present(alertController, animated: true)
    }
    
    private func shouldAddDataToCap(for name: String, completion: @escaping (Bool) -> ()) {
        let alertController = UIAlertController(title: "Limit Reached",
                                                message: "\(name) has reached their data cap. Do you want to extend it?",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .default) { (_) in
            completion(false)
        })
        
        alertController.addAction(UIAlertAction(title: "No", style: .default) { (_) in
            completion(true)
        })
        
        present(alertController, animated: true)
    }
    
}

extension HostWebSessionViewController: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
        browserViewController.dismiss(animated: true)
        
        guard !peerIDsToAdd.isEmpty else { return }
        
        let templateMessage = "How many MB of data would you like to provide "

        let alertController = UIAlertController(title: "Data Cap",
                                                message: templateMessage + "\(peerIDsToAdd.first!.displayName)?",
                                                preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Data Cap"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let textFieldText = alertController.textFields?.first!.text?.nilIfEmpty() ?? "10"
            self.users.append(User(peerID: self.peerIDsToAdd.first!, dataSet: DataSet()))
            guard let numFromText = Int(textFieldText) else { return }
            self.users[self.users.count - 1].dataSet.dataCap = Byte(numFromText * 1000000)
            self.peerIDsToAdd.removeFirst()
            guard !self.peerIDsToAdd.isEmpty else { return }
            alertController.message = templateMessage + "\(self.peerIDsToAdd.first!.displayName)?"
            alertController.textFields?.first!.text = ""
            self.present(alertController, animated: true)
        })
        present(alertController, animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        peerIDsToAdd.removeAll()
        browserViewController.dismiss(animated: true)
    }
}

extension HostWebSessionViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let searchRequest = try? PropertyListDecoder().decode(SearchRequest.self, from: data),
            let userIndex = self.users.index(where: { (user) -> Bool in
                return user.peerID == peerID
            }) else { return }
        if users[userIndex].dataSet.limitReached() {
            shouldAddDataToCap(for: peerID.displayName) { (should) in
                guard should else {
                    self.removePeer(peerID)
                    return
                }
                self.getDataAmountToAdd(to: peerID.displayName, completion: { (bytes) in
                    guard let bytes = bytes else { return }
                    self.users[userIndex].dataSet.dataCap += bytes
                })
            }
        } else {
            getSearchResult(forSearchRequest: searchRequest) { [weak self] (webPage) in
                guard let webPage = webPage,
                    let strongSelf = self else { return }
                strongSelf.users[userIndex].dataSet.dataUsed += CGFloat(webPage.data.count)
                let searchResult = SearchResult(webPage: webPage, dataSet: strongSelf.users[userIndex].dataSet)
                strongSelf.sendSearchResult(searchResult, toPeer: peerID)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard peerID.displayName != "Host",
            state == MCSessionState.connected,
            !peerIDsToAdd.contains(peerID),
            !users.contains(where: { user in
                return user.peerID == peerID }) else { return }
        peerIDsToAdd.append(peerID)
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
    
    // TODO: Figure out better way of managing user agents
    func searchFor(_ url: URL) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if userAgent == .mobile {
            let urlRequest = URLRequest(url: url)
            webView?.load(urlRequest)
        } else {
        let searchRequest = SearchRequest(url: url, userAgent: userAgent)
            getSearchResult(forSearchRequest: searchRequest) { (webPage) in
                guard let webPage = webPage else { return }
                self.webView?.loadWebPage(webPage)
            }
        }
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
    
    func leaveSession() {
        session.disconnect()
        assistant.stop()
        dismiss(animated: true)
    }
    
    func addDataForPeer(_ peerID: MCPeerID) {
        guard let userIndex = users.index(where: { (user) -> Bool in
            return user.peerID == peerID
        }) else { return }
        getDataAmountToAdd(to: users[userIndex].peerID.displayName) { [weak self] (bytes) in
            guard let bytes = bytes,
                let strongSelf = self else { return }
            strongSelf.users[userIndex].dataSet.dataCap += bytes
        }
    }
    
    func removePeer(_ peerID: MCPeerID) {
        guard let userIndex = users.index(where: { (user) -> Bool in
            return user.peerID == peerID
        }) else { return }
        users.remove(at: userIndex)
        guard let disconnect = "disconnect".data(using: .utf8) else { return }
        do {
            try session.send(disconnect, toPeers: [peerID], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
}

