//
//  URL+DomainNameURL.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/5/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

extension URL {
    var domainNameURL: URL {
        var urlRemovingInitialCasesOfForwardSlash = absoluteString.replacingOccurrences(of: "//www.", with: ".www\\")
        guard let indexToStartRemoval = urlRemovingInitialCasesOfForwardSlash.index(of: "/") else { return self }
        urlRemovingInitialCasesOfForwardSlash.removeSubrange(indexToStartRemoval...)
        let domainNameURLString = urlRemovingInitialCasesOfForwardSlash.replacingOccurrences(of: ".www\\", with: "//www.")
        return URL(string: domainNameURLString)!
    }
}
