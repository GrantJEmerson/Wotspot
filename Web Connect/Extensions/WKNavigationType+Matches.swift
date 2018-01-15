//
//  WKNavigationType+Matches.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/14/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import WebKit

extension WKNavigationType {
    
    func matchesAnyOf(_ types: [WKNavigationType]) -> Bool {
        for type in types {
            guard self == type else { continue }
            return true
        }
        return false
    }
}
