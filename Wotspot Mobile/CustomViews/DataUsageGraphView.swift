//
//  DataUsageGraphView.swift
//  Wotspot
//
//  Created by Grant Emerson on 12/23/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

class DataUsageGraphView: UIView {
    
    // MARK: Properties
    
    open var dataSet: DataSet = DataSet(0, 10) {
        didSet { update() }
    }
    
    private let fontSize: CGFloat = 15
    private let normalPadding: CGFloat = 8
    private let extraPadding: CGFloat = 30
    
    private var graphWidth: CGFloat {
        return bounds.width - (normalPadding * 2)
    }
        
    private var usedDataGraphViewWidth: NSLayoutConstraint!
    
    private lazy var usedDataTitleLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = .boldSystemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var availableDataTitleLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = .boldSystemFont(ofSize: fontSize)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usedDataAmountLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = .boldSystemFont(ofSize: fontSize)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var availableDataAmountLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = .boldSystemFont(ofSize: fontSize)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usedDataGraphView: GradientView = {
        let view = GradientView()
        view.colors = [#colorLiteral(red: 0.2641793575, green: 0.5471587531, blue: 0.6843655133, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        view.locations = [0.8, 1]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var availableDataGraphView: GradientView = {
        let view = GradientView()
        view.colors = [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0.4862745098, green: 0.7176470588, blue: 0.8588235294, alpha: 1)]
        view.locations = [0, 0.2, 1]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var enclosingDataGraphView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Functions
    
    open func update() {
        let cap = dataSet.dataCap
        let used = dataSet.dataUsed
        
        guard cap >= used, cap != 0 else { return }
        
        DispatchQueue.main.async {
            self.usedDataGraphViewWidth.constant = (used / cap) * self.graphWidth
            self.layoutIfNeeded()
            
            self.usedDataAmountLabel.text = "\(self.dataSet.usedPercentage())%"
            self.availableDataAmountLabel.text = "\(self.dataSet.availablePercentage())%"
            
            let usedDataInMB = used.toMegabytes()
            let availableDataInMB = cap.toMegabytes() - usedDataInMB
            
            self.usedDataTitleLabel.text = "Used - \(usedDataInMB)mb"
            self.availableDataTitleLabel.text = "Available - \(availableDataInMB)mb"
        }
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        add(enclosingDataGraphView, usedDataTitleLabel, availableDataTitleLabel)
        enclosingDataGraphView.add(usedDataGraphView, availableDataGraphView)
        
        usedDataGraphView.addSubview(usedDataAmountLabel)
        availableDataGraphView.addSubview(availableDataAmountLabel)
        
        usedDataGraphViewWidth = usedDataGraphView.widthAnchor.constraint(equalToConstant: 0).withPriority(999)
        
        NSLayoutConstraint.activate([
            
            enclosingDataGraphView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -normalPadding),
            enclosingDataGraphView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: normalPadding),
            enclosingDataGraphView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -normalPadding).withPriority(999),

            usedDataGraphView.leadingAnchor.constraint(equalTo: enclosingDataGraphView.leadingAnchor),
            usedDataGraphView.topAnchor.constraint(equalTo: enclosingDataGraphView.topAnchor),
            usedDataGraphView.bottomAnchor.constraint(equalTo: enclosingDataGraphView.bottomAnchor),
            usedDataGraphViewWidth,
            
            availableDataGraphView.trailingAnchor.constraint(equalTo: enclosingDataGraphView.trailingAnchor),
            availableDataGraphView.topAnchor.constraint(equalTo: enclosingDataGraphView.topAnchor),
            availableDataGraphView.bottomAnchor.constraint(equalTo: enclosingDataGraphView.bottomAnchor),
            availableDataGraphView.leadingAnchor.constraint(equalTo: usedDataGraphView.trailingAnchor).withPriority(999),
            
            usedDataAmountLabel.centerYAnchor.constraint(equalTo: usedDataGraphView.centerYAnchor),
            usedDataAmountLabel.centerXAnchor.constraint(equalTo: usedDataGraphView.centerXAnchor),
            
            availableDataAmountLabel.centerYAnchor.constraint(equalTo: availableDataGraphView.centerYAnchor),
            availableDataAmountLabel.centerXAnchor.constraint(equalTo: availableDataGraphView.centerXAnchor),
            
            usedDataTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: normalPadding),
            usedDataTitleLabel.bottomAnchor.constraint(equalTo: enclosingDataGraphView.topAnchor),
            usedDataTitleLabel.heightAnchor.constraint(equalToConstant: extraPadding),
            usedDataTitleLabel.leadingAnchor.constraint(equalTo: enclosingDataGraphView.leadingAnchor),
            
            availableDataTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: normalPadding),
            availableDataTitleLabel.bottomAnchor.constraint(equalTo: enclosingDataGraphView.topAnchor),
            availableDataTitleLabel.heightAnchor.constraint(equalToConstant: extraPadding),
            availableDataTitleLabel.trailingAnchor.constraint(equalTo: enclosingDataGraphView.trailingAnchor)
        ])
    }
    
}
