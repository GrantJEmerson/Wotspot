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
            NetworkService.getImagesFor(htmlURLs) { (urlImageDictionary) in
                print(urlImageDictionary)
            }
            let webPage = WebPage(data: data,
                                  url: responseBaseURL,
                                  mimeType: responseMimeType,
                                  textEncoding: responseCharacterEncoding)
            completion(webPage)
        }.resume()
    }
    
    class func getImagesFor(_ urls: [URL], completion: @escaping (([String: UIImage]) -> ())) {
        var urlImageDictionary = [String: UIImage]()
        for url in urls {
            getImageFor(url) { (image) in
                guard let image = image else { return }
                urlImageDictionary[url.absoluteString] = image
            }
        }
        completion(urlImageDictionary)
    }
    
    class func getImageFor(_ url: URL, completion: @escaping (UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { completion(nil); return }
            completion(UIImage(data: data))
        }.resume()
    }
}
