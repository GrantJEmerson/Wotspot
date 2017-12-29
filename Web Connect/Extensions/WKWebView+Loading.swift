//
//  WKWebView+Loading.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/19/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import WebKit

extension WKWebView {
    
    var screenshot: UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
    
    func loadWebPage(_ webPage: WebPage) {
        DispatchQueue.main.async {
            self.load(webPage.data, mimeType: webPage.mimeType, characterEncodingName: webPage.textEncoding, baseURL: webPage.url)
        }
    }
}
