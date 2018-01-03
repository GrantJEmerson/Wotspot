//
//  CustomWebView.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/19/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import WebKit

class CustomWebView: WKWebView {
    
    public var backwardURLs: [URL]?
    public var forwardURLs: [URL]?
    
    func loadWebPage(_ webPage: WebPage) {
        DispatchQueue.main.async {
            self.load(webPage.data, mimeType: webPage.mimeType, characterEncodingName: webPage.textEncoding, baseURL: webPage.url)
        }
    }
}
