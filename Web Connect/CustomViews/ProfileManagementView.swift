//
//  ProfileManagementView.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/23/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class ProfileManagementView: UIView {
    
    // MARK: Properties
    
    private let buttonHeight: CGFloat = 44
    
    private let seperatorView1 = SeperatorView()
    private let seperatorView2 = SeperatorView()
    private let seperatorView3 = SeperatorView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.font = UIFont(name: "Futura", size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userNameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "User ID"
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // TODO: Make sure people can't add Host as their name
    private lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = "User ID"
        textField.textAlignment = .right
        textField.textColor = .lightGray
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var dataUsageGraph: DataUsageGraphView = {
        let dataUsageGraph = DataUsageGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        dataUsageGraph.translatesAutoresizingMaskIntoConstraints = false
        return dataUsageGraph
    }()
    
    private lazy var leaveSessionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Leave Session", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(leaveSessionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        setUpSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: "IBActions"
    
    @objc private func leaveSessionButtonTapped() {
        
    }
    
    // MARK: Public Functions
    
    public func updateDataUsageGraph(withDataSet dataSet: DataSet) {
        dataUsageGraph.dataSet = dataSet
    }
    
    // MARK: Private Functions
    
    private func setUpSubViews() {
        
        addSubviews([
            titleLabel, seperatorView1, userNameTitleLabel, userNameTextField, seperatorView2,
            dataUsageGraph, seperatorView3, leaveSessionButton])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            seperatorView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            seperatorView1.leadingAnchor.constraint(equalTo: leadingAnchor),
            seperatorView1.trailingAnchor.constraint(equalTo: trailingAnchor).withPriority(999),
            
            userNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).withPriority(999),
            userNameTextField.topAnchor.constraint(equalTo: seperatorView1.bottomAnchor),
            userNameTextField.widthAnchor.constraint(equalToConstant: 100).withPriority(999),
            userNameTextField.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            userNameTitleLabel.topAnchor.constraint(equalTo: userNameTextField.topAnchor),
            userNameTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            userNameTitleLabel.heightAnchor.constraint(equalToConstant: buttonHeight),
            userNameTitleLabel.trailingAnchor.constraint(equalTo: userNameTextField.leadingAnchor),
            
            seperatorView2.topAnchor.constraint(equalTo: userNameTitleLabel.bottomAnchor),
            seperatorView2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            seperatorView2.trailingAnchor.constraint(equalTo: seperatorView1.trailingAnchor),

            dataUsageGraph.leadingAnchor.constraint(equalTo: leadingAnchor),
            dataUsageGraph.trailingAnchor.constraint(equalTo: trailingAnchor),
            dataUsageGraph.topAnchor.constraint(equalTo: seperatorView2.bottomAnchor),
            dataUsageGraph.bottomAnchor.constraint(equalTo: seperatorView3.topAnchor),
            
            seperatorView3.bottomAnchor.constraint(equalTo: leaveSessionButton.topAnchor),
            seperatorView3.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            seperatorView3.trailingAnchor.constraint(equalTo: seperatorView1.trailingAnchor),
            
            leaveSessionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            leaveSessionButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            leaveSessionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        ])
    }
}

extension ProfileManagementView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .red
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .lightGray
    }
}
