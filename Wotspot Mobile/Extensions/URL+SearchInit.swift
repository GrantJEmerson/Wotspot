//
//  URL+SearchInit.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/1/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

extension URL {
    
    init?(search: String) {
        guard search.isLink else {
            let urlSearchString = search.replacingOccurrences(of: " ", with: "+")
            self.init(string: "https://www.google.com/search?q=" + urlSearchString)
            return
        }
        var search = search
        if !(search.hasPrefix("https://www.") || search.hasPrefix("http://www.")) {
            search = "https://www." + search
        }
        self.init(string: search)
    }
}
