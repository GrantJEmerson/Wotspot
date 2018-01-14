//
//  String+NilIfEmpty.swift
//  InterBrowse
//
//  Created by Grant Emerson on 12/29/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import Foundation

extension String {
    func nilIfEmpty() -> String? {
        guard !self.isEmpty else { return nil }
        return self
    }
}
