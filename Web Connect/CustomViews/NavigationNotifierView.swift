//
//  NavigationNotifierView.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/6/18.
//  Copyright © 2018 Celebrity Games. All rights reserved.
//

import UIKit


final public class NavigationNotifierView: UIView {
    
    public enum DrawDirection {
        case backwards, forwards
    }
    
    let drawDirection: DrawDirection
    
    public init(frame: CGRect, drawDirection: DrawDirection) {
        self.drawDirection = drawDirection
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        
        // Direction Factor For X Coordinates
        let x: CGFloat = drawDirection == .backwards ? 1 : -1
                
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        let color = UIColor.black
        
        //// Gradient Declarations
        let gradient = CGGradient(colorsSpace: nil, colors: [UIColor.darkGray.cgColor, UIColor.darkGray.blended(withFraction: 0.5, of: UIColor.white).cgColor, UIColor.white.cgColor] as CFArray, locations: [0, 0.51, 1])!
        
        //// Oval Drawing
        context.saveGState()
        context.setAlpha(0.6)
        
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: drawDirection == .backwards ? -rect.width : 0, y: -10, width: rect.width * 2, height: rect.height + 20))
        context.saveGState()
        ovalPath.addClip()
        UIView.animate(withDuration: 0.8) {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0.5, y: -14), end: CGPoint(x: 0.5, y: self.bounds.height), options: [])
        }
        context.restoreGState()
        
        context.restoreGState()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: rect.midX - 10, y: rect.midY))
        bezierPath.addLine(to: CGPoint(x: rect.midX + 10, y: rect.midY))
        bezierPath.close()
        UIColor.gray.setFill()
        bezierPath.fill()
        color.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        context.saveGState()
        context.translateBy(x: rect.midX - 10 * x, y: rect.midY - 10)
        
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 0.4 * x, y: 9))
        bezier2Path.addLine(to: CGPoint(x: 4.4 * x, y: 9))
        bezier2Path.addLine(to: CGPoint(x: 7.4 * x, y: 4))
        bezier2Path.addCurve(to: CGPoint(x: 11.4 * x, y: 0), controlPoint1: CGPoint(x: 7.4 * x, y: 4), controlPoint2: CGPoint(x: 13.15 * x, y: -1.25))
        bezier2Path.addCurve(to: CGPoint(x: 0.4 * x, y: 9), controlPoint1: CGPoint(x: 9.65 * x, y: 1.25), controlPoint2: CGPoint(x: 0.4 * x, y: 9))
        bezier2Path.close()
        color.setFill()
        bezier2Path.fill()
        color.setStroke()
        bezier2Path.lineWidth = 1
        bezier2Path.stroke()
        
        context.restoreGState()
        
        
        //// Bezier 3 Drawing
        context.saveGState()
        context.translateBy(x: rect.midX - 10 * x, y: rect.midY)
        
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 0.4 * x, y: 0))
        bezier3Path.addLine(to: CGPoint(x: 4.4 * x, y: 0))
        bezier3Path.addLine(to: CGPoint(x: 7.4 * x, y: 5))
        bezier3Path.addCurve(to: CGPoint(x: 11.4 * x, y: 9), controlPoint1: CGPoint(x: 7.4 * x, y: 5), controlPoint2: CGPoint(x: 13 * x, y: 10))
        bezier3Path.addCurve(to: CGPoint(x: 0.4 * x, y: 0), controlPoint1: CGPoint(x: 9.8 * x, y: 8), controlPoint2: CGPoint(x: 0.4 * x, y: 0))
        bezier3Path.close()
        color.setFill()
        bezier3Path.fill()
        color.setStroke()
        bezier3Path.lineWidth = 1
        bezier3Path.stroke()
        
        context.restoreGState()
    }
    
    public func show() {
        setNeedsDisplay()
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.4, delay: 1, options: .curveEaseInOut, animations: {
                self.alpha = 0
            })
        }
    }
}

private extension UIColor {
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        var r1: CGFloat = 1, g1: CGFloat = 1, b1: CGFloat = 1, a1: CGFloat = 1
        var r2: CGFloat = 1, g2: CGFloat = 1, b2: CGFloat = 1, a2: CGFloat = 1
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
                       green: g1 * (1 - fraction) + g2 * fraction,
                       blue: b1 * (1 - fraction) + b2 * fraction,
                       alpha: a1 * (1 - fraction) + a2 * fraction);
    }
}
