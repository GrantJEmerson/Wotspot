//
//  NotificationName+Custom.swift
//  Wotspot
//
//  Created by Grant Emerson on 12/22/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let startEditing = Notification.Name("startEditing")
    static let endEditing = Notification.Name("endEditing")
    static let darkenLabels = Notification.Name("darkenLabels")
    static let lightenLabels = Notification.Name("lightenLabels")
}
