//
//  UIVisualEffectView+SwitchStyle.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/8/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

extension UIVisualEffectView {
    
    func switchBlurEffectStyle() {
        let isDark = UIBlurEffectStyle.current == .dark
        let newEffect = isDark ? UIBlurEffect.light : .dark
        UserDefaults.standard.set(!isDark, forKey: "prefersDark")
        UIView.animate(withDuration: 0.8) {
            self.effect = newEffect
        }
        UIBlurEffectStyle.current = isDark ? .extraLight : .dark
        NotificationCenter.default.post(Notification(name: isDark ? .darkenLabels : .lightenLabels))
    }
}

extension UIBlurEffect {
    static let dark = UIBlurEffect(style: .dark)
    static let light = UIBlurEffect(style: .extraLight)
}

extension UIBlurEffectStyle {
    // Work around because UIBlurEffects are not equatable!!
    static var current: UIBlurEffectStyle = UserDefaults.standard.bool(forKey: "prefersDark") ? .dark : .extraLight
}

