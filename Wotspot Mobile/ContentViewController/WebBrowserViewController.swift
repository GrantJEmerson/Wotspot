//
//  WebBrowserViewController.swift
//  Wotspot
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import WebKit

@objc public protocol ParentDelegate: class {
    func setPulleyPosition(_ pulleyPosition: Int)
    func searchFor(_ url: URL)
    @objc optional func goBack()
    @objc optional func goForward()
}

class WebBrowserViewController: UIViewController {
    
    // MARK: Properties
    
    public weak var delegate: ParentDelegate?
    
    private var isHost: Bool
    
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    private var lastOffsetY: CGFloat = 0
    private let bottomSpacing: CGFloat = -60
    private let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    private var webViewTopConstraint: NSLayoutConstraint?
    private var webViewBottomConstraint: NSLayoutConstraint?
    
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
    
    public lazy var webView: CustomWebView = {
        let webView = isHost ? CustomWebView() : CustomWebView(frame: .zero, configuration: configuration)
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = isHost
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var backwardsNavigationView: NavigationNotifierView = {
        let view = NavigationNotifierView(frame: .zero, drawDirection: .backwards)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private lazy var forwardNavigationView: NavigationNotifierView = {
        let view = NavigationNotifierView(frame: .zero, drawDirection: .forwards)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
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
        
        setUpSubviews()
        loadHomePage()

        guard !isHost else { return }
        view.addGestureRecognizer(leftEdgePanRecognizer)
        view.addGestureRecognizer(rightEdgePanRecognizer)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let isLeftSideActivated = (size.width >= 600.0)
        if isLeftSideActivated {
            webViewBottomConstraint?.constant = 0
            guard !isPad else { return }
            webViewTopConstraint?.constant = 0
        } else {
            webViewBottomConstraint?.constant = bottomSpacing
            webViewTopConstraint?.constant = statusBarHeight
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: Selector Functions

    @objc private func leftScreenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            delegate?.goBack!()
            backwardsNavigationView.show()
        }
    }
    
    @objc private func rightScreenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            delegate?.goForward!()
            forwardNavigationView.show()
        }
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        view.add(webView)
        
        webViewBottomConstraint = webView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                  constant: isPad ? 0 : bottomSpacing)
        webViewTopConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor,
                                                            constant: statusBarHeight)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewTopConstraint!,
            webViewBottomConstraint!
        ])
        
        guard !isHost else { return }
        
        view.add(backwardsNavigationView, forwardNavigationView)
        
        NSLayoutConstraint.activate([
            backwardsNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backwardsNavigationView.topAnchor.constraint(equalTo: webView.topAnchor),
            backwardsNavigationView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            backwardsNavigationView.widthAnchor.constraint(equalToConstant: 100),
            
            forwardNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forwardNavigationView.topAnchor.constraint(equalTo: webView.topAnchor),
            forwardNavigationView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            forwardNavigationView.widthAnchor.constraint(equalToConstant: 100),
        ])
        
        backwardsNavigationView.setNeedsDisplay()
        forwardNavigationView.setNeedsDisplay()
    }
    
    private func loadHomePage() {
        if isHost {
            let _ = webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        } else {
            let _ = webView.loadHTMLString(WebErrorPage.offline, baseURL: nil)
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
        decisionHandler(.allow)
        guard var url = navigationAction.request.url,
            navigationAction.navigationType.matchesAnyOf([.linkActivated, .backForward, .reload]),
            !isHost else { return }
        if navigationAction.navigationType == .reload { url = webView.url! }
        delegate?.searchFor(url)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        lastOffsetY = 0
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        let removeLongPressPopUpScript = "document.body.style.webkitTouchCallout='none';"
        webView.evaluateJavaScript(removeLongPressPopUpScript)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Web view failed to load webPage due to error: ", error.localizedDescription)
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
