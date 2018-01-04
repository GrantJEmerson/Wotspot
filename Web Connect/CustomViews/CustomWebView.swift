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
        
        print("Before Process Byte Count:", webPage.data.count)

        let imageEncodedHTMLResponse = webPage.data.dataEncodedWithLocalUrlsFrom(webPage.images)
        let imageEncodedData = imageEncodedHTMLResponse.htmlData
        let imageURLs = imageEncodedHTMLResponse.imageURLs

        print("After Process Byte Count:", imageEncodedData.count)

        let cachedHTMLURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension(".html")

        do {
            try imageEncodedData.write(to: cachedHTMLURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        DispatchQueue.main.async {
//            self.load(webPage.data, mimeType: webPage.mimeType, characterEncodingName: webPage.textEncoding, baseURL: webPage.url)
            let urlRequest = URLRequest(url: cachedHTMLURL)
            self.load(urlRequest)
        }
        
        // Clean Up
        
        do {
            try FileManager.default.removeItem(at: cachedHTMLURL)
            try imageURLs.forEach({ try FileManager.default.removeItem(at: $0) })
        } catch {
            print(error.localizedDescription)
        }
    }
}

private extension Data {
    
    func dataEncodedWithLocalUrlsFrom(_ urlImageDataDictionary: [String: Data]) -> (htmlData: Data, imageURLs: [URL]) {
        
        var html = String(data: self, encoding: .utf8)!
        var imageURLs = [URL]()
        
        for (internetURLString, image) in urlImageDataDictionary {
            let imageUUID = UUID().uuidString
            let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageUUID)
            imageURLs.append(imageURL)
            do {
                try image.write(to: imageURL)
            } catch {
                print(error.localizedDescription)
            }
            html = html.replacingOccurrences(of: internetURLString, with: imageURL.absoluteString)
        }
        return (html.data(using: .utf8)!, imageURLs)
    }
}
