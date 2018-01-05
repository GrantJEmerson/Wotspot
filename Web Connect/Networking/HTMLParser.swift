//
//  HTMLParser.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/3/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

public class HTMLParser {
    
    class func imageSourcesIn(_ html: String) -> [URL] {
        let htmlSeperatedByImageTags = html.components(separatedBy: "<img")
        var sources = [URL]()
        for htmlBlock in htmlSeperatedByImageTags {
            let htmlSeperatedBySourceTag = htmlBlock.components(separatedBy: "src=\"")
            guard htmlSeperatedBySourceTag.count > 1,
                let source = htmlSeperatedBySourceTag[1].components(separatedBy: "\"").first,
                source.isLink,
                let url = URL(string: source) else { continue }
            sources.append(url)
        }
        return sources
    }
    
    class func linkTagSourcesIn(_ html: String) -> [URL] {
        let htmlSeperatedByLinkTags = html.components(separatedBy: "<link")
        var sources = [URL]()
        for htmlBlock in htmlSeperatedByLinkTags {
            let htmlSeperatedBySourceTag = htmlBlock.components(separatedBy: "href=\"")
            guard htmlSeperatedBySourceTag.count > 1,
                let source = htmlSeperatedBySourceTag[1].components(separatedBy: "\"").first,
                source.isLink,
                let url = URL(string: source) else { continue }
            sources.append(url)
        }
        return sources
    }
}
