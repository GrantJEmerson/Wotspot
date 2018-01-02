//
//  UserManagmentView.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/23/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol UserManagementViewDelegate {
    func addUsers()
    func endSession()
    func addDataForPeer(_ peerID: MCPeerID)
    func removePeer(_ peerID: MCPeerID)
}

class UserManagementView: UIView {
    
    // MARK: Properties
    
    public var delegate: UserManagementViewDelegate?
    
    public var users = [User]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.userCountLabel.text = "\(self.users.count) of 7 Users Connected"
                self.addUsersButton.isEnabled = self.users.count < 7
            }
        }
    }
    
    private let spacing: CGFloat = 8
    
    private let cellID = "cellID"
    
    private let seperatorView1 = SeperatorView()
    
    private lazy var titleLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.text = "Manage Users"
        label.font = UIFont(name: "Futura", size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addUsersButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.addTarget(self, action: #selector(addUsers), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var userCountLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.text = "0 of 7 Users Connected"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 15, right: 0)
        tableView.rowHeight = 170
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let endSessionFooterView = EndSessionFooterView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 35))
        endSessionFooterView.userManagementView = self
        tableView.tableFooterView = endSessionFooterView
        
        return tableView
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubViews()
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func setUpSubViews() {
        
        addSubviews([titleLabel, addUsersButton, seperatorView1, userCountLabel, tableView])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            addUsersButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            addUsersButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            addUsersButton.widthAnchor.constraint(equalToConstant: 40),
            addUsersButton.heightAnchor.constraint(equalToConstant: 40),
            
            seperatorView1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            seperatorView1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing).withPriority(999),
            seperatorView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            userCountLabel.topAnchor.constraint(equalTo: seperatorView1.bottomAnchor),
            userCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            userCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing).withPriority(999),
            userCountLabel.heightAnchor.constraint(equalToConstant: 24),
            
            tableView.topAnchor.constraint(equalTo: userCountLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).withPriority(999)
        ])
    }
    
    @objc private func addUsers() {
        delegate?.addUsers()
    }
}

extension UserManagementView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect (x:0, y: 0, width:10, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
}

extension UserManagementView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserTableViewCell
        cell.user = users[indexPath.section]
        cell.delegate = self
        return cell
    }
}

extension UserManagementView: ParentUserManagementViewDelegate {
    
    func removePeer(_ peerID: MCPeerID) {
        delegate?.removePeer(peerID)
    }
    
    func addDataForPeer(_ peerID: MCPeerID) {
        delegate?.addDataForPeer(peerID)
    }
}
