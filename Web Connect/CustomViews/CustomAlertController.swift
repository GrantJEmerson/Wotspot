//
//  CustomAlertController.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/12/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import UIKit

class CustomAlertController: UIAlertController {
    
    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAlertController()
    }
    
    // MARK: Private Functions
    
    private func setUpAlertController() {
        view.tintColor = .themeColor
        
    }

}
