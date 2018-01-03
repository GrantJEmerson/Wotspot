//
//  NetworkService.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/2/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

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
            let webPage = WebPage(data: data,
                                  url: responseBaseURL,
                                  mimeType: responseMimeType,
                                  textEncoding: responseCharacterEncoding)
            completion(webPage)
        }.resume()
    }
}
