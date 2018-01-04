//
//  String+Links.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/4/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

extension String {
    var isLink: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && self.count > 0) else { return false }
        if detector!.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) > 0 {
            return true
        }
        return false
    }
}
