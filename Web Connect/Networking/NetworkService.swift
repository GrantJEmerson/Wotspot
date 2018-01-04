//
//  NetworkService.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/2/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import UIKit

public class NetworkService {
    
    class func getSearchResult(forSearchRequest searchRequest: SearchRequest,
                               completion: @escaping (WebPage?) -> ()) {
        var urlRequest = URLRequest(url: searchRequest.url)
        urlRequest.addValue(searchRequest.userAgent.rawValue, forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { completion(nil); return }
            let responseMimeType = response?.mimeType ?? ""
            let responseBaseURL = response?.url ?? URL(string: "https://www.google.com")!
            let responseCharacterEncoding = response?.textEncodingName ?? String.Encoding.utf8.description
            guard let html = String(data: data, encoding: .utf8) else { return }
            let htmlURLs = HTMLParser.imageSourcesIn(html)
            NetworkService.getImageDataFor(htmlURLs) { (urlImageDictionary) in
                let webPage = WebPage(data: data,
                                      url: responseBaseURL,
                                      mimeType: responseMimeType,
                                      textEncoding: responseCharacterEncoding,
                                      images: urlImageDictionary)
                completion(webPage)
            }
        }.resume()
    }
    
    class func getImageDataFor(_ urls: [URL], completion: @escaping ([String: Data]) -> ()) {
        var urlImageDictionary = [String: Data]()
        var urlsCompleted = 0
        for url in urls {
            getImageFor(url) { (image) in
                urlsCompleted += 1
                guard let image = image else {
                    if urlsCompleted == urls.count { completion(urlImageDictionary) }
                    return
                }
                urlImageDictionary[url.absoluteString] = image
                if urlsCompleted == urls.count { completion(urlImageDictionary) }
            }
        }
    }
    
    class func getImageFor(_ url: URL, completion: @escaping (Data?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
