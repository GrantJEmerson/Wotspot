//
//  UserTableViewCell.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/27/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    public var user: User? {
        didSet {
            guard let user = user else { return }
            usernameLabel.text = user.peerID.displayName
            update(dataUsed: user.dataSet.dataUsed, dataCap: user.dataSet.dataCap)
        }
    }
    
    private let spacing: CGFloat = 8
    
    private let seperatorView1 = SeperatorView()
    private let seperatorView2 = SeperatorView()
    private let seperatorView3 = SeperatorView()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dataUsedPercentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dataUsageGraph: DataUsageGraphView = {
        let dataUsageGraph = DataUsageGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        dataUsageGraph.translatesAutoresizingMaskIntoConstraints = false
        return dataUsageGraph
    }()
    
    private let addDataButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Data", for: .normal)
        button.setTitleColor(.defaultButtonColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backgroundBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let effectView = UIVisualEffectView(effect: effect)
        return effectView
    }()
    
    // MARK: Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 3
        backgroundColor = .clear
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func setUpViews() {
        
        addSubviews([
            backgroundBlurView, usernameLabel, dataUsedPercentageLabel, seperatorView1,
            dataUsageGraph, seperatorView2, removeButton, seperatorView3, addDataButton])
        
        backgroundBlurView.constrainToParent()
        
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            
            dataUsedPercentageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            dataUsedPercentageLabel.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            
            seperatorView1.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            seperatorView1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            seperatorView1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            
            dataUsageGraph.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            dataUsageGraph.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            dataUsageGraph.topAnchor.constraint(equalTo: seperatorView1.bottomAnchor),
            dataUsageGraph.bottomAnchor.constraint(equalTo: seperatorView2.topAnchor),
            
            seperatorView2.bottomAnchor.constraint(equalTo: removeButton.topAnchor),
            seperatorView2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            seperatorView2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            
            removeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            removeButton.bottomAnchor.constraint(equalTo: seperatorView3.topAnchor),
            
            seperatorView3.bottomAnchor.constraint(equalTo: addDataButton.topAnchor),
            seperatorView3.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            seperatorView3.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            
            addDataButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addDataButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func update(dataUsed: Byte, dataCap: Byte) {
        dataUsageGraph.dataSet.dataUsed = dataUsed
        dataUsageGraph.dataSet.dataCap = dataCap
        dataUsedPercentageLabel.text = "-used \(Int(dataUsed/dataCap))%"
    }
}
