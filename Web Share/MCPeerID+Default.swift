//
//  MCPeerID+Default.swift
//  Web Share
//
//  Created by Grant Emerson on 1/2/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit
import MultipeerConnectivity

extension MCPeerID {
    static let saved = MCPeerID(displayName: UserDefaults.standard.object(forKey: "displayName") as? String
        ?? Host.current().localizedName ?? "Mac")
}
