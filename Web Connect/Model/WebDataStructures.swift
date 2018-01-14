//
//  DataStructures.swift
//  InterBrowse
//
//  Created by Grant Emerson on 12/7/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import MultipeerConnectivity

enum UserAgent: String, Codable {
    case mobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
    case desktop = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/604.5.3 (KHTML, like Gecko) Version/11.0.3 Safari/604.5.3"
}

struct WebPage: Codable {
    let html: Data
    let resources: [Resource]
    let url: URL
    let mimeType: String
    let textEncoding: String
}

struct Resource: Codable {
    let internetURL: String
    let data: Data
}

struct SearchRequest: Codable {
    let url: URL
    let userAgent: UserAgent
    init(url: URL, userAgent: UserAgent = .desktop) {
        self.url = url
        self.userAgent = userAgent
    }
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
