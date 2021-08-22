//
//  CustomPanelBehavior.swift
//  jejuPublic
//
//  Created by Hyun on 2021/08/20.
//

import Foundation
import FloatingPanel

class CustomPanelBehavior: FloatingPanelBehavior {
    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
            return false
        }
}
