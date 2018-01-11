//
//  PiChartView.swift
//  Web Share
//
//  Created by Grant Emerson on 1/7/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class PiChartView: NSView {
    
    // MARK: Properties
    
    open var percentage: CGFloat = 1 {
        didSet {
            piChart.percentage = percentage
            percentageLabel.stringValue = "\(Int(percentage * 100))%"
        }
    }
    
    private lazy var percentageLabel: NSTextField = {
        let textField = NSTextField()
        textField.isEditable = false
        textField.drawsBackground = false
        textField.isBezeled = false
        textField.stringValue = "75%"
        textField.alignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var piChart: PiChart = {
        let piChart = PiChart()
        piChart.translatesAutoresizingMaskIntoConstraints = false
        return piChart
    }()
    
    // MARK: Init
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setUpSubviews()
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        addSubview(percentageLabel)
        addSubview(piChart)
        
        NSLayoutConstraint.activate([
            piChart.trailingAnchor.constraint(equalTo: trailingAnchor),
            piChart.topAnchor.constraint(equalTo: topAnchor),
            piChart.bottomAnchor.constraint(equalTo: bottomAnchor),
            piChart.widthAnchor.constraint(equalTo: piChart.heightAnchor),
            
            percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            percentageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            percentageLabel.trailingAnchor.constraint(equalTo: piChart.leadingAnchor)
        ])
    }
}

class PiChart: NSView {
    
    // MARK: Properties
    
    open var percentage: CGFloat = 1 {
        didSet {
            self.draw(bounds)
        }
    }
    
    // MARK: Draw
    override func draw(_ dirtyRect: NSRect) {
        let ovalRect = dirtyRect
        let ovalPath = NSBezierPath()
        ovalPath.appendArc(withCenter: NSPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 3.5, startAngle: 0, endAngle: (360.0 - percentage * 360) + 0.0001, clockwise: true)
        ovalPath.line(to: NSPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()
        NSColor.darkGray.setFill()
        ovalPath.fill()
    }
}
