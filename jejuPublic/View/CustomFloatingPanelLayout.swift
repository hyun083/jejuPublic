//
//  CustomFlotingPanelLayout.swift
//  jejuPublic
//
//  Created by Hyun on 2021/08/20.
//

import Foundation
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
//                .full: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .superview), absoluteInset: 260.0
                .half: FloatingPanelLayoutAnchor(absoluteInset: 225.0, edge: .bottom, referenceGuide: .superview),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 110.0, edge: .bottom, referenceGuide: .superview)
            ]
        }
}

