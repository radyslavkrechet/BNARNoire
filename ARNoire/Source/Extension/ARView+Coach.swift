//
//  ARView+Coach.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 16.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import ARKit
import RealityKit

extension ARView {
    func coach(for goal: ARCoachingOverlayView.Goal, delegate: ARCoachingOverlayViewDelegate) {
        var coachingOverlayView: ARCoachingOverlayView!

        if let view = subviews.first(where: { $0 is ARCoachingOverlayView }) {
            coachingOverlayView = view as? ARCoachingOverlayView
        } else {
            coachingOverlayView = ARCoachingOverlayView(frame: bounds)
            addSubview(coachingOverlayView)
        }

        coachingOverlayView.session = session
        coachingOverlayView.goal = goal
        coachingOverlayView.delegate = delegate
        coachingOverlayView.activatesAutomatically = true

        if !coachingOverlayView.isActive {
            coachingOverlayView.setActive(true, animated: true)
        }
    }
}
