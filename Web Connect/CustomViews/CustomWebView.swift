//
//  CustomWebView.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/19/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import WebKit

class CustomWebView: WKWebView {
    
    // MARK: Properties
    
    public var backwardURLs: [URL]?
    public var forwardURLs: [URL]?
    
    // MARK: Public Functions
    
    func loadWebPage(_ webPage: WebPage) {
        
        let resourceEncodedHTMLResponse = webPage.html.dataEncodedWithLocalUrlsFrom(webPage.resources)
        let resourceEncodedData = resourceEncodedHTMLResponse.htmlData
        let resourceURLs = resourceEncodedHTMLResponse.resourceURLs

        let cachedHTMLURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension(".html")

        do {
            try resourceEncodedData.write(to: cachedHTMLURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        DispatchQueue.main.async {
//            self.load(webPage.data, mimeType: webPage.mimeType, characterEncodingName: webPage.textEncoding, baseURL: webPage.url)
            let urlRequest = URLRequest(url: cachedHTMLURL)
            self.load(urlRequest)
        }
        
        // NSTemporary Directory: Clean Up
        
        do {
            try FileManager.default.removeItem(at: cachedHTMLURL)
            try resourceURLs.forEach({ try FileManager.default.removeItem(at: $0) })
        } catch {
            print(error.localizedDescription)
        }
    }
}

private extension Data {
    
    func dataEncodedWithLocalUrlsFrom(_ resources: [Resource]) -> (htmlData: Data, resourceURLs: [URL]) {
        
        var html = String(data: self, encoding: .utf8)!
        var resourceURLs = [URL]()
        
        for resource in resources {
            let resourceUUID = UUID().uuidString
            let resourceURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(resourceUUID)
            resourceURLs.append(resourceURL)
            do {
                try resource.data.write(to: resourceURL)
            } catch {
                print(error.localizedDescription)
            }
            html = html.replacingOccurrences(of: resource.internetURL, with: resourceURL.absoluteString)
        }
        
        return (html.data(using: .utf8)!, resourceURLs)
    }
}
