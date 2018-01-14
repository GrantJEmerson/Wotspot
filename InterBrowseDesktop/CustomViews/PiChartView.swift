//
//  PiChartView.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/7/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import AppKit

class PiChartView: NSView {
    
    // MARK: Properties
    
    open var percentage: Int = 100 {
        didSet {
            DispatchQueue.main.async {
                self.piChart.percentageAvailable = CGFloat(self.percentage) / 100
                self.percentageLabel.stringValue = "\(self.percentage)%"
            }
        }
    }
    
    private lazy var percentageLabel: NSTextField = {
        let textField = NSTextField()
        textField.isEditable = false
        textField.drawsBackground = false
        textField.isBezeled = false
        textField.stringValue = "100%"
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
    
    open var percentageAvailable: CGFloat = 1 {
        didSet { needsDisplay = true }
    }
    
    // MARK: Draw
    override func draw(_ dirtyRect: NSRect) {
        let ovalRect = dirtyRect
        let ovalPath = NSBezierPath()
        let endAngle = 360 - percentageAvailable * 360 + 0.0001
        ovalPath.appendArc(withCenter: NSPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 3.5, startAngle: 0, endAngle: endAngle, clockwise: true)
        if percentageAvailable != 1 {
            ovalPath.line(to: NSPoint(x: ovalRect.midX, y: ovalRect.midY))
        }
        ovalPath.close()
        NSColor.white.setFill()
        ovalPath.fill()
        NSColor.black.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()
    }
}
