//
//  UserTableViewCell.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/27/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol UserTableViewCellDelegate {
    func addDataForPeer(_ peerID: MCPeerID)
    func removePeer(_ peerID: MCPeerID)
}

class UserTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    public var delegate: UserTableViewCellDelegate?
    
    public var user: User? {
        didSet {
            guard let user = user else { return }
            usernameLabel.text = user.peerID.displayName
            update(dataSet: user.dataSet)
        }
    }
    
    private let spacing: CGFloat = 8
    
    private let seperatorView1 = SeperatorView()
    private let seperatorView2 = SeperatorView()
    private let seperatorView3 = SeperatorView()
    
    private let usernameLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dataUsedPercentageLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dataUsageGraph: DataUsageGraphView = {
        let dataUsageGraph = DataUsageGraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 150)) // Frame needed for constraint set up to work properly
        dataUsageGraph.translatesAutoresizingMaskIntoConstraints = false
        return dataUsageGraph
    }()
    
    private lazy var addDataButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Data", for: .normal)
        button.setTitleColor(.defaultButtonColor, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.addTarget(self, action: #selector(addData), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpCellView()
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selector Functions

    @objc private func addData() {
        guard let user = user else { return }
        delegate?.addDataForPeer(user.peerID)
    }
    
    @objc private func disconnect() {
        guard let user = user else { return }
        delegate?.removePeer(user.peerID)
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        
        addSubviews([
            usernameLabel, dataUsedPercentageLabel, seperatorView1, dataUsageGraph,
            seperatorView2, removeButton, seperatorView3, addDataButton])
        
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
    
    private func setUpCellView() {
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 3
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
    }
    
    private func update(dataSet: DataSet) {
        dataUsageGraph.dataSet = dataSet
        dataUsedPercentageLabel.text = "-used \(dataSet.usedPercentage())%"
    }
}
