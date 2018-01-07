//
//  NetworkService.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/2/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import UIKit

final public class NetworkService {
    
    class func getSearchResult(forSearchRequest searchRequest: SearchRequest,
                               completion: @escaping (WebPage?) -> ()) {
        var urlRequest = URLRequest(url: searchRequest.url)
        urlRequest.addValue(searchRequest.userAgent.rawValue, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { completion(nil); return }
            let responseMimeType = response?.mimeType ?? ""
            let responseCharacterEncoding = response?.textEncodingName ?? String.Encoding.utf8.description
            guard var html = String(data: data, encoding: .utf8) else { completion(nil); return }
            html = HTMLParser.removeLocalURLInstancesFrom(html, with: searchRequest.url.domainNameURL.absoluteString)
            let resourceURLs = HTMLParser.imageSourcesIn(html) + HTMLParser.linkTagSourcesIn(html)
            NetworkService.getResourcesFor(resourceURLs) { (resources) in
                let webPage = WebPage(html: html.data(using: .utf8)!, resources: resources, url: searchRequest.url,
                                      mimeType: responseMimeType, textEncoding: responseCharacterEncoding)
                completion(webPage)
            }
        }.resume()
    }
    
    class func getResourcesFor(_ urls: [URL], completion: @escaping ([Resource]) -> ()) {
        var resources = [Resource]()
        var urlsCompleted = 0
        guard !urls.isEmpty else { completion([]); return }
        for url in urls {
            getDataFor(url) { data in
                urlsCompleted += 1
                guard let data = data else {
                    if urlsCompleted == urls.count { completion(resources) }
                    return
                }
                let newResource = Resource(internetURL: url.absoluteString, data: data)
                resources.append(newResource)
                if urlsCompleted == urls.count { completion(resources) }
            }
        }
    }
    
    class func getDataFor(_ url: URL, completion: @escaping (Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
