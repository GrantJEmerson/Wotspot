//
//  Defaults.swift
//  Web Share
//
//  Created by Grant Emerson on 1/12/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Cocoa

struct PreferenceKey<Value> : RawRepresentable {
    typealias RawValue = String
    let rawValue: RawValue
    
    init (_ key: String) {
        rawValue = key
    }
    
    // Appease the protocol.
    init (rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
}

extension Notification.Name {
    static let appearanceChanged = Notification.Name(rawValue: "AppearanceChangedNotification")
    static let beginBookmarkEditing = Notification.Name(rawValue: "BeginEditing")
    static let endBookmarkEditing = Notification.Name(rawValue: "EndEditing")
}

extension UserDefaults {
    subscript(key: PreferenceKey<Bool>) -> Bool {
        set { set(newValue, forKey: key.rawValue) }
        get { return bool(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<String>) -> String? {
        set { set(newValue, forKey: key.rawValue) }
        get { return string(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Double>) -> Double {
        set { set(newValue, forKey: key.rawValue) }
        get { return double(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceKey<Int>) -> Int {
        set { set(newValue, forKey: key.rawValue) }
        get { return integer(forKey: key.rawValue) }
    }
}

// User defaults for our application
extension UserDefaults {
    
    static let peerIDKey = PreferenceKey<String>("PeerID")
    static let useDarkModeKey = PreferenceKey<Bool>("UseDarkMode")
    
    static var peerID: String {
        get {
            return UserDefaults.standard[peerIDKey] ?? Host.current().localizedName ?? "Mac"
        }
    }
    
    static var useDarkMode: Bool {
        get {
            return UserDefaults.standard[useDarkModeKey]
        }
    }
}

