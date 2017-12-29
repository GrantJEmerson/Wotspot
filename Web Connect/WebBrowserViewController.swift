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
    
    private var lastOffsetY: CGFloat = 0
    
    public lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false    
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    
    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)

        ])
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
