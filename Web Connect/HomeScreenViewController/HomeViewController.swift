//
//  HomeViewController.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/9/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let buttonHeight: CGFloat = 50
    private let buttonWidth: CGFloat = 200
    
    private let backgroundGradientView: PastelView = {
        let view = PastelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonGroupingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let HomePageButton: () -> (UIButton) = {
        let button = UIButton()
        button.setTitleColor(.defaultButtonColor, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 50 / 3
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private lazy var hostSessionButton: UIButton = {
        let button = HomePageButton()
        button.isEnabled = Reachability.isConnectedToNetwork()
        button.setTitle("Host", for: .normal)
        button.addTarget(self, action: #selector(startHostingSessionTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var joinSessionButton: UIButton = {
        let button = HomePageButton()
        button.setTitle("Join", for: .normal)
        button.addTarget(self, action: #selector(joinAvailableSessionTapped), for: .touchUpInside)
        return button
    }()
    
    private let selectionOrTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 18)
        label.text = "or"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundGradientView.startAnimation()
    }
    
    // MARK: Selector Functions
    
    @objc private func startHostingSessionTapped() {
        presentHostWebSessionVC()
    }
    
    @objc private func joinAvailableSessionTapped() {
        presentUserWebSessionVC()
    }
    
    // MARK: - Private Functions
    
    private func setUpSubviews() {
        
        view.addSubview(backgroundGradientView)
        buttonGroupingView.addSubviews([hostSessionButton, joinSessionButton, selectionOrTextLabel])
        view.addSubview(buttonGroupingView)
        
        backgroundGradientView.constrainToParent()
        
        NSLayoutConstraint.activate([
            buttonGroupingView.widthAnchor.constraint(greaterThanOrEqualToConstant: buttonWidth),
            buttonGroupingView.heightAnchor.constraint(equalToConstant: buttonHeight * 2 + 10),
            buttonGroupingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonGroupingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            selectionOrTextLabel.leadingAnchor.constraint(equalTo: buttonGroupingView.leadingAnchor),
            selectionOrTextLabel.trailingAnchor.constraint(equalTo: buttonGroupingView.trailingAnchor),
            selectionOrTextLabel.centerYAnchor.constraint(equalTo: buttonGroupingView.centerYAnchor),
            selectionOrTextLabel.heightAnchor.constraint(equalToConstant: 30),
            
            hostSessionButton.leadingAnchor.constraint(equalTo: buttonGroupingView.leadingAnchor),
            hostSessionButton.trailingAnchor.constraint(equalTo: buttonGroupingView.trailingAnchor),
            hostSessionButton.topAnchor.constraint(equalTo: buttonGroupingView.topAnchor),
            hostSessionButton.bottomAnchor.constraint(equalTo: selectionOrTextLabel.topAnchor),
            
            joinSessionButton.leadingAnchor.constraint(equalTo: buttonGroupingView.leadingAnchor),
            joinSessionButton.trailingAnchor.constraint(equalTo: buttonGroupingView.trailingAnchor),
            joinSessionButton.bottomAnchor.constraint(equalTo: buttonGroupingView.bottomAnchor),
            joinSessionButton.topAnchor.constraint(equalTo: selectionOrTextLabel.bottomAnchor),
        ])
    }
    
    private func presentHostWebSessionVC() {
        let webBrowserVC = WebBrowserViewController(isHost: true)
        let webSesionDrawerVC = WebSessionDrawerViewController(isHost: true)
        let hostWebSessionVC = HostWebSessionViewController(contentViewController: webBrowserVC,
                                                            drawerViewController: webSesionDrawerVC)
        hostWebSessionVC.webView = webBrowserVC.webView
        hostWebSessionVC.drawerDelegate = webSesionDrawerVC
        webSesionDrawerVC.delegate = hostWebSessionVC
        webBrowserVC.delegate = hostWebSessionVC
        self.show(hostWebSessionVC, sender: self)
    }
    
    private func presentUserWebSessionVC() {
        let webBrowserVC = WebBrowserViewController(isHost: false)
        let webSesionDrawerVC = WebSessionDrawerViewController(isHost: false)
        let userWebSessionVC = UserWebSessionViewController(contentViewController: webBrowserVC,
                                                            drawerViewController: webSesionDrawerVC)
        userWebSessionVC.webView = webBrowserVC.webView
        userWebSessionVC.drawerDelegate = webSesionDrawerVC
        webSesionDrawerVC.delegate = userWebSessionVC
        webBrowserVC.delegate = userWebSessionVC
        self.show(userWebSessionVC, sender: self)
    }
}
