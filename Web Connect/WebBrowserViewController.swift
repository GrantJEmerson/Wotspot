//
//  WebBrowserViewController.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import WebKit

public protocol ParentDelegate {
    func setPulleyPosition(_ pulleyPosition: Int)
    func searchFor(_ url: URL)
}

class WebBrowserViewController: UIViewController {
    
    // MARK: Properties
    
    public var delegate: ParentDelegate?
    
    private var isHost: Bool
    
    private var lastOffsetY: CGFloat = 0
    
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
        let webView = isHost ? WKWebView() : WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = isHost
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var leftEdgePanRecognizer: UIScreenEdgePanGestureRecognizer = {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftScreenEdgeSwiped(_:)))
        edgePan.edges = .left
        return edgePan
    }()
    
    private lazy var rightEdgePanRecognizer: UIScreenEdgePanGestureRecognizer = {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(rightScreenEdgeSwiped(_:)))
        edgePan.edges = .right
        return edgePan
    }()
    
    // MARK: View Controller Life Cycle & Init
    
    init(isHost: Bool) {
        self.isHost = isHost
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor,
                                         constant: UIApplication.shared.statusBarFrame.height),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                            constant: UIDevice.current.userInterfaceIdiom == .pad ? 0 : -60)
        ])

        guard !isHost else { return }
        view.addGestureRecognizer(leftEdgePanRecognizer)
        view.addGestureRecognizer(rightEdgePanRecognizer)
    }
    
    // MARK: Private Functions
    
    @objc private func leftScreenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
        }
    }
    
    @objc private func rightScreenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
        }
    }
    
}

extension WebBrowserViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > lastOffsetY else { return }
        delegate?.setPulleyPosition(PulleyPosition.collapsed.rawValue)
    }
}

extension WebBrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
            navigationAction.navigationType.matchesAnyOf([.linkActivated, .backForward, .reload]) else {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        delegate?.searchFor(url)
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        lastOffsetY = 0
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        
        guard webView.url?.absoluteString.hasPrefix("https://www.google.com") ?? false else { return }
        webView.evaluateJavaScript("document.getElementById('_fZl').onclick.toString();") { (message, _) in
        }
    }
}

extension WebBrowserViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let message = message.body as? String,
            message.hasPrefix("Search: ") else { return }
        let search = message.replacingOccurrences(of: "Search: ", with: "")
        guard let url = URL(search: search) else { return }
        delegate?.searchFor(url)
    }
}

extension WKNavigationType {
    
    func matchesAnyOf(_ types: [WKNavigationType]) -> Bool {
        for type in types {
            guard self == type else { continue }
            return true
        }
        return false
    }
}
