//
//  CustomWebView.swift
//  InterBrowse
//
//  Created by Grant Emerson on 12/19/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import WebKit

class CustomWebView: WKWebView {
    
    // MARK: Properties
    
    public var loadedHTMLURL: URL?
    
    override var url: URL? {
        return loadedHTMLURL
    }
    
    public var backwardURLs = [URL]()
    public var forwardURLs = [URL]()
    
    private var currentCachedHTMLUrl: URL?
    private var currentCachedResourcesUrls = [URL]()
    
    // MARK: Init
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        addObserver(self, forKeyPath: "isLoading", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard !isLoading else { return }
        cleanTemporaryDirectory()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrided Functions
    
    override func load(_ request: URLRequest) -> WKNavigation? {
        super.load(request)
        guard let url = request.url,
            url.absoluteString.isLink else { return nil }
        loadedHTMLURL = url
        return nil
    }
    
    // MARK: Public Functions
    
    func loadWebPage(_ webPage: WebPage) {
        
        let resourceEncodedHTMLResponse = webPage.html.dataEncodedWithLocalUrlsFrom(webPage.resources)
        let resourceEncodedData = resourceEncodedHTMLResponse.htmlData
        currentCachedResourcesUrls = resourceEncodedHTMLResponse.resourceURLs

        let cachedHTMLURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("html")
        currentCachedHTMLUrl = cachedHTMLURL
        do {
            try resourceEncodedData.write(to: cachedHTMLURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        DispatchQueue.main.async {
            let urlRequest = URLRequest(url: cachedHTMLURL)
            let _ = self.load(urlRequest)
            self.loadedHTMLURL = webPage.url
        }
    }
    
    private func cleanTemporaryDirectory() {
        
        guard let currentCachedHTMLUrl = currentCachedHTMLUrl else { return }
        
        do {
            try FileManager.default.removeItem(at: currentCachedHTMLUrl)
            try currentCachedResourcesUrls.forEach({ try FileManager.default.removeItem(at: $0) })
        } catch {
            print(error.localizedDescription)
        }
        
        self.currentCachedHTMLUrl = nil
        currentCachedResourcesUrls.removeAll()
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
