//
//  URL+SearchInit.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/1/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

extension URL {
    
    init?(search: String) {
        let urlSearchString = search.replacingOccurrences(of: " ", with: "+")
        self.init(string: "https://www.google.com/search?q=" + urlSearchString)
    }
}
