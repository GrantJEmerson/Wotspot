//
//  PulleyViewController+Nested.swift
//  Pulley
//
//  Created by Ethan Gill on 8/1/17.
//

import UIKit

extension PulleyViewController: PulleyDrawerViewControllerDelegate {
    
    public func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 60.0 + bottomSafeArea
    }

    public func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 290.0 + bottomSafeArea
    }

    public func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }

    public func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            drawerVCCompliant.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: bottomSafeArea)
        }
    }

    public func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            drawerVCCompliant.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: bottomSafeArea)
        }
    }

    public func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            drawerVCCompliant.drawerChangedDistanceFromBottom?(drawer: drawer, distance: distance, bottomSafeArea: bottomSafeArea)
        }
    }
}
