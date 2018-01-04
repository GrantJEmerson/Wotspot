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
    
        let imageEncodedData = webPage.data.dataEncodedWithLocalUrlsFrom(webPage.images)
        
        DispatchQueue.main.async {
            self.load(imageEncodedData, mimeType: webPage.mimeType, characterEncodingName: webPage.textEncoding, baseURL: webPage.url)
        }
    }
}

private extension Data {
    
    func dataEncodedWithLocalUrlsFrom(_ urlImageDataDictionary: [String: Data]) -> Data {
        
        var html = String(data: self, encoding: .utf8)!
        
        for (internetURLString, image) in urlImageDataDictionary {
            let imageUUID = UUID().uuidString
            let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageUUID)
            do {
                try image.write(to: imageURL)
            } catch {
                print(error.localizedDescription)
            }
            html = html.replacingOccurrences(of: internetURLString, with: imageURL.absoluteString)
        }
        
        return html.data(using: .utf8)!
    }
}
