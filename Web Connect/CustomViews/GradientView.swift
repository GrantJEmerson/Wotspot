//
//  GradientView.swift
//  Gradient View
//
//  Created by Sam Soffes on 10/27/09.
//  Copyright (c) 2009-2014 Sam Soffes. All rights reserved.
//

import UIKit

/// Simple view for drawing gradients and borders.
@IBDesignable open class GradientView: UIView {

	// MARK: - Types

    public enum Mode {
		case linear, radial
	}

	public enum Direction {
		case vertical, horizontal
	}

	// MARK: - Properties

	open var colors: [UIColor]? {
		didSet { updateGradient() }
	}
    
	open var dimmedColors: [UIColor]? {
		didSet {
			updateGradient()
		}
	}
    
	open var automaticallyDims: Bool = true
    
	open var locations: [CGFloat]? {
		didSet {
			updateGradient()
		}
	}

    open var mode: Mode = .linear {
		didSet {
			setNeedsDisplay()
		}
	}
    
	open var direction: Direction = .horizontal {
		didSet {
			setNeedsDisplay()
		}
	}

	@IBInspectable open var drawsThinBorders: Bool = true {
		didSet {
			setNeedsDisplay()
		}
	}

	@IBInspectable open var topBorderColor: UIColor? {
		didSet {
			setNeedsDisplay()
		}
	}

	@IBInspectable open var rightBorderColor: UIColor? {
		didSet {
			setNeedsDisplay()
		}
	}

	@IBInspectable open var bottomBorderColor: UIColor? {
		didSet {
			setNeedsDisplay()
		}
	}

	@IBInspectable open var leftBorderColor: UIColor? {
		didSet {
			setNeedsDisplay()
		}
	}


	// MARK: - UIView

    override open func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		let size = bounds.size

		// Gradient
		if let gradient = gradient {
			let options: CGGradientDrawingOptions = [.drawsAfterEndLocation]

			if mode == .linear {
                
                let startPoint = CGPoint.zero
                let endPoint = (direction == .vertical ? CGPoint(x: 0, y: size.height) :
                    CGPoint(x: size.width, y: 0))
 
				context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: options)
			} else {
				let center = CGPoint(x: bounds.midX, y: bounds.midY)
				context?.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: min(size.width, size.height) / 2, options: options)
			}
		}

		let screen: UIScreen = window?.screen ?? UIScreen.main
		let borderWidth: CGFloat = drawsThinBorders ? 1.0 / screen.scale : 1.0

		if let color = topBorderColor {
			context?.setFillColor(color.cgColor)
			context?.fill(CGRect(x: 0, y: 0, width: size.width, height: borderWidth))
		}

		let sideY: CGFloat = topBorderColor != nil ? borderWidth : 0
		let sideHeight: CGFloat = size.height - sideY - (bottomBorderColor != nil ? borderWidth : 0)

		if let color = rightBorderColor {
			context?.setFillColor(color.cgColor)
			context?.fill(CGRect(x: size.width - borderWidth, y: sideY, width: borderWidth, height: sideHeight))
		}

		if let color = bottomBorderColor {
			context?.setFillColor(color.cgColor)
			context?.fill(CGRect(x: 0, y: size.height - borderWidth, width: size.width, height: borderWidth))
		}

		if let color = leftBorderColor {
			context?.setFillColor(color.cgColor)
			context?.fill(CGRect(x: 0, y: sideY, width: borderWidth, height: sideHeight))
		}
	}

	override open func tintColorDidChange() {
		super.tintColorDidChange()

		if automaticallyDims {
			updateGradient()
		}
	}

	override open func didMoveToWindow() {
		super.didMoveToWindow()
		contentMode = .redraw
	}


	// MARK: - Private

	fileprivate var gradient: CGGradient?

	fileprivate func updateGradient() {
		gradient = nil
		setNeedsDisplay()

		let colors = gradientColors()
		if let colors = colors {
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let colorSpaceModel = colorSpace.model

			let gradientColors = colors.map { (color: UIColor) -> AnyObject! in
				let cgColor = color.cgColor
				let cgColorSpace = cgColor.colorSpace ?? colorSpace

				if cgColorSpace.model == colorSpaceModel {
					return cgColor as AnyObject!
				}

				var red: CGFloat = 0
				var blue: CGFloat = 0
				var green: CGFloat = 0
				var alpha: CGFloat = 0
				color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
				return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor as AnyObject!
			} as NSArray

			gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: locations)
		}
	}

	fileprivate func gradientColors() -> [UIColor]? {
		if tintAdjustmentMode == .dimmed {
			if let dimmedColors = dimmedColors {
				return dimmedColors
			}

			if automaticallyDims {
				if let colors = colors {
					return colors.map {
						var hue: CGFloat = 0
						var brightness: CGFloat = 0
						var alpha: CGFloat = 0

						$0.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)

						return UIColor(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
					}
				}
			}
		}

		return colors
	}
}
