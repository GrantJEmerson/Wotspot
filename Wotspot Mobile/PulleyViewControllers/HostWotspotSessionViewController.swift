//
//  HostWotspotSessionViewController.swift
//  Wotspot
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import CoreData
import MultipeerConnectivity
import WebKit

class HostWotspotSessionViewController: PulleyViewController {
    
    // MARK: Properties
    
    public weak var webView: CustomWebView?
    public weak var drawerDelegate: WotspotSessionDrawerDelegate?
    
    private var peerIDsToAdd = [MCPeerID]()
    
    private var users = [User]() {
        didSet { drawerDelegate?.updateUsers(users) }
    }
    
    private lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    @available(iOS 10.0, *)
    private lazy var moc = appDelegate?.persistentContainer.viewContext
    
    private var userAgent = UserAgent.mobile
    
    private lazy var dataCapTextFieldConfigurtationHandler: ((UITextField) -> Void) = { textField in
        textField.placeholder = "Data Cap"
        textField.keyboardType = .numberPad
        textField.font = UIFont(name: "Futura", size: 18)
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    private lazy var peerID: MCPeerID = {
        let peerID = MCPeerID(displayName: "Host")
        return peerID
    }()
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        return session
    }()
    
    private lazy var browser: MCBrowserViewController = {
        let browser = MCBrowserViewController(serviceType: "Wotspot", session: session)
        browser.delegate = self
        browser.view.tintColor = .themeColor
        return browser
    }()
    
    private lazy var assistant: MCAdvertiserAssistant = {
        let assistant = MCAdvertiserAssistant(serviceType: "Wotspot", discoveryInfo: nil, session: session)
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
    
    private func decodeMultipeerConnectivityData(_ data: Data, from peerID: MCPeerID) {
        guard let searchRequest = try? PropertyListDecoder().decode(SearchRequest.self, from: data),
            let userIndex = self.users.index(where: { (user) -> Bool in
                return user.peerID == peerID
            }) else { return }
        if users[userIndex].dataSet.limitReached() {
            manageDataLimitReachedFor(peerID, at: userIndex)
        } else {
            NetworkService.getSearchResult(forSearchRequest: searchRequest) { [weak self] (webPage) in
                guard let strongSelf = self else { return }
                if let webPage = webPage {
                    let resourceDataCount = webPage.resources.reduce(0, { (dataCount, resource) in
                        return dataCount + resource.data.count
                    })
                    let totalDataCount = webPage.html.count + resourceDataCount
                    strongSelf.users[userIndex].dataSet.dataUsed += CGFloat(totalDataCount)
                    let searchResult = SearchResult(webPage: webPage, dataSet: strongSelf.users[userIndex].dataSet)
                    strongSelf.sendSearchResult(searchResult, toPeer: peerID)
                } else {
                    self?.send("Not-Found", toPeer: peerID)
                }
            }
        }
    }
    
    private func sendSearchResult(_ searchResult: SearchResult, toPeer peer: MCPeerID) {
        guard let data = try? PropertyListEncoder().encode(searchResult) else { return }
        do {
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func send(_ message: String, toPeer peer: MCPeerID) {
        guard let command = message.data(using: .utf8) else { return }
        do {
            try session.send(command, toPeers: [peer], with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func manageDataLimitReachedFor(_ peerID: MCPeerID, at userIndex: Int) {
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
    }
    
    private func shouldAddDataToCap(for name: String, completion: @escaping (Bool) -> ()) {
        let alertController = CustomAlertController(title: "Limit Reached",
                                                message: "\(name) has reached their data cap. Do you want to extend it?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default) { (_) in
            completion(false)
        })
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            completion(true)
        })
        
        present(alertController, animated: true)
    }
    
    private func getDataAmountToAdd(to name: String, completion: @escaping (Byte?) -> ()) {
        
        let alertController = CustomAlertController(title: "Add Data",
                                                message: "How many MB of data would you like to add to \(name)?",
                                                preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: dataCapTextFieldConfigurtationHandler)
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            let textFieldText = alertController.textFields?.first!.text?.nilIfEmpty() ?? "0"
            guard let numFromText = Int(textFieldText) else { completion(nil); return }
            let bytes = Byte(numFromText * 1000000)
            completion(bytes)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(nil)
        })
        
        present(alertController, animated: true)
    }
    
    private func presentDataCapAlertControllers() {
        guard !peerIDsToAdd.isEmpty else { return }
        
        let templateMessage = "How many MB of data would you like to provide "
        
        let alertController = CustomAlertController(title: "Data Cap",
                                                message: templateMessage + "\(peerIDsToAdd.first!.displayName)?",
                                                preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: dataCapTextFieldConfigurtationHandler)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let textFieldText = alertController.textFields?.first!.text?.nilIfEmpty() ?? "10"
            let newUser = User(peerID: self.peerIDsToAdd.first!, dataSet: DataSet())
            self.users.append(newUser)
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
    
}

extension HostWotspotSessionViewController: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
        presentDataCapAlertControllers()
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
        peerIDsToAdd.removeAll()
    }
}

extension HostWotspotSessionViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        decodeMultipeerConnectivityData(data, from: peerID)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard peerID.displayName != "Host" else { return }
        switch state {
        case .connected:
            guard !peerIDsToAdd.contains(peerID),
                !users.contains(where: { user in
                return user.peerID == peerID }) else { return }
            peerIDsToAdd.append(peerID)
        case .notConnected:
            guard let userIndex = users.index(where: { (user) -> Bool in
                return user.peerID == peerID
            }) else { return }
            users.remove(at: userIndex)
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension HostWotspotSessionViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 3 // Makes sure data cap is below 1 GB
    }
}

extension HostWotspotSessionViewController: ContentDelegate, ParentDelegate {
    
    var currentURL: URL? {
        return webView?.url
    }
    
    func searchFor(_ url: URL) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if userAgent == .mobile {
            let urlRequest = URLRequest(url: url)
            let _ = webView?.load(urlRequest)
        } else {
            let searchRequest = SearchRequest(url: url, userAgent: userAgent)
            NetworkService.getSearchResult(forSearchRequest: searchRequest) { (webPage) in
                guard let webPage = webPage else { return }
                self.webView?.loadWebPage(webPage)
            }
        }
        drawerDelegate?.updateBookmarkIconFor(url)
    }
    
    func reload() {
        webView?.reload()
    }
    
    func cancel() {
        webView?.stopLoading()
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
    
    func addUsers() {
        present(browser, animated: true)
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
        send("disconnect", toPeer: peerID)
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

