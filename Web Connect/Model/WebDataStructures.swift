//
//  DataStructures.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import MultipeerConnectivity

enum UserAgent: String, Codable {
    case mobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
    case desktop = ""
}

struct WebPage: Codable {
    let data: Data
    let url: URL
    let mimeType: String
    let textEncoding: String
    let images: [String: Data]
}

struct SearchRequest: Codable {
    let url: URL
    let userAgent: UserAgent
}

struct SearchResult: Codable {
    let webPage: WebPage
    let dataSet: DataSet
}

struct User {
    let peerID: MCPeerID
    var dataSet: DataSet
}

struct DataSet: Codable {
    var dataUsed: Byte
    var dataCap: Byte
    
    init(_ dataUsed: Byte = 0, _ dataCap: Byte = 0) {
        self.dataUsed = dataUsed
        self.dataCap = dataCap
    }
    
    func limitReached() -> Bool {
        return dataUsed >= dataCap
    }
    
    func usedPercentage() -> Int {
        return Int(dataUsed/dataCap * 100)
    }
    
    func availablePercentage() -> Int {
        return 100 - self.usedPercentage()
    }
}

typealias Byte = CGFloat

extension Byte {
    func toMegabytes() -> Int {
        let byteToMegaByteConversionRate: Byte = 1000000
        return Int(self/byteToMegaByteConversionRate)
    }
}
