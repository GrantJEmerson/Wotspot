//
//  AdaptiveLabel.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/1/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import UIKit

class AdaptiveLabel: UILabel {
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: Private Functions
    
    private func setUp() {
        
        textColor = UserDefaults.standard.bool(forKey: "prefersDark") ? .white : .black
        
        NotificationCenter.default.addObserver(forName: .lightenLabels, object: nil, queue: .main) { (_) in
            UIView.transition(with: self, duration: 0.8, options: .transitionCrossDissolve, animations: {
                self.textColor = .white
            })
        }
        
        NotificationCenter.default.addObserver(forName: .darkenLabels, object: nil, queue: .main) { (_) in
            UIView.transition(with: self, duration: 0.8, options: .transitionCrossDissolve, animations: {
                self.textColor = .black
            })
        }
    }
}
