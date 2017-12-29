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
        let isDark = (effect == UIBlurEffect.dark)
        let newEffect = isDark ? UIBlurEffect.light : .dark
        UserDefaults.standard.set(!isDark, forKey: "prefersDark")
        UIView.animate(withDuration: 0.8) {
            self.effect = newEffect
        }
    }
}

extension UIBlurEffect {
    static let dark = UIBlurEffect(style: .dark)
    static let light = UIBlurEffect(style: .extraLight)
}


