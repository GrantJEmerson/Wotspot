//
//  PreferencesViewController.swift
//  Wotspot
//
//  Created by Grant Emerson on 1/12/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class PreferencesViewController: NSViewController {
    @IBAction func didToggleDarkMode(_ sender: NSButton) {
        NotificationCenter.default.post(name: .appearanceChanged, object: nil)
    }
}
