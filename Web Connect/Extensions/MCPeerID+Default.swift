//
//  MCPeerID+Default.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/30/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension MCPeerID {
    static let saved = MCPeerID(displayName: UserDefaults.standard.object(forKey: "displayName") as? String
                                            ?? UIDevice.current.name)
}
