//
//  ViewController.swift
//  Test
//
//  Created by Radyslav Krechet on 16.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

let shortSubtitlesDelay = 4.0
let longSubtitlesDelay = 10.0
let subtitlesLengthBreakValue = 82

private let labelTopBottomInset: CGFloat = 2
private let labelLeftRightInset: CGFloat = 6
private let labelNumberOfLines = 0
private let labelBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
private let constraintMultiplier: CGFloat = 1
private let constraintConstant: CGFloat = 0

enum TrakingTarget {
    case floor, wall, face, desk
}

protocol ViewProtocol: class {
    func runSession(with trakingTarget: TrakingTarget)
    func showScene(with anchor: HasAnchoring, subtitles: String?)
    func showClue(_ clue: String)
    func showSubtitles(_ subtitles: String)
}

class ViewController: UIViewController, ViewProtocol, ARCoachingOverlayViewDelegate {
    @IBOutlet private(set) var arView: ARView!

    private var clueLabel: PaddingLabel!
    private var subtitlesLabel: PaddingLabel!
    private var presenter: PresenterProtocol!
    private var isCoaching = false
    private var scene: (anchor: HasAnchoring, subtitles: String?)?
    private var clueTimer: Timer?
    private var subtitlesTimer: Timer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = Presenter(view: self)
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.startExperience()
    }

    // MARK: - ViewProtocol

    func runSession(with trakingTarget: TrakingTarget) {
        arView.scene.anchors.removeAll()

        clueLabel.isHidden = true
        subtitlesLabel.isHidden = true

        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]

        switch trakingTarget {
        case .floor, .wall, .desk:
            let isWallTrakingTarget = trakingTarget == .wall

            let configuration = ARWorldTrackingConfiguration()
            configuration.environmentTexturing = .automatic
            configuration.planeDetection = isWallTrakingTarget ? .vertical : .horizontal
            arView.session.run(configuration, options: options)

            let goal: ARCoachingOverlayView.Goal = isWallTrakingTarget ? .verticalPlane : .horizontalPlane
            isCoaching = true
            arView.coach(for: goal, delegate: self)
        case .face:
            let configuration = ARFaceTrackingConfiguration()
            arView.session.run(configuration, options: options)
        }
    }

    func showScene(with anchor: HasAnchoring, subtitles: String?) {
        scene = (anchor, subtitles)
        showScene()
    }

    func showClue(_ clue: String) {
        clueTimer?.invalidate()

        clueLabel.text = "ViewController.newClue".localized.uppercased() + "\n\(clue)"
        clueLabel.isHidden = false

        clueTimer = Timer.scheduledTimer(withTimeInterval: shortSubtitlesDelay, repeats: false) { [weak self] _ in
            self?.clueLabel.isHidden = true
        }
    }

    func showSubtitles(_ subtitles: String) {
        subtitlesTimer?.invalidate()

        subtitlesLabel.text = subtitles
        subtitlesLabel.isHidden = false

        let subtitlesDelay = subtitles.count > subtitlesLengthBreakValue ? longSubtitlesDelay : shortSubtitlesDelay

        subtitlesTimer = Timer.scheduledTimer(withTimeInterval: subtitlesDelay, repeats: false) { [weak self] _ in
            self?.subtitlesLabel.isHidden = true
        }
    }

    // MARK: - ARCoachingOverlayViewDelegate

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false

        isCoaching = false
        showScene()
    }

    // MARK: - Private

    private func setupViews() {
        arView.automaticallyConfigureSession = false

        let insets = UIEdgeInsets(top: labelTopBottomInset,
                                  left: labelLeftRightInset,
                                  bottom: labelTopBottomInset,
                                  right: labelLeftRightInset)
        

        clueLabel = PaddingLabel()
        clueLabel.insets = insets
        clueLabel.numberOfLines = labelNumberOfLines
        clueLabel.textColor = UIColor.white
        clueLabel.backgroundColor = labelBackgroundColor
        clueLabel.translatesAutoresizingMaskIntoConstraints = false
        clueLabel.isHidden = true
        arView.addSubview(clueLabel)

        arView.addConstraints([
            NSLayoutConstraint(item: clueLabel!,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: arView,
                               attribute: .leading,
                               multiplier: constraintMultiplier,
                               constant: constraintConstant),

            NSLayoutConstraint(item: clueLabel!,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: arView,
                               attribute: .centerY,
                               multiplier: constraintMultiplier,
                               constant: constraintConstant)
        ])

        subtitlesLabel = PaddingLabel()
        subtitlesLabel.insets = insets
        subtitlesLabel.textAlignment = .center
        subtitlesLabel.numberOfLines = labelNumberOfLines
        subtitlesLabel.textColor = UIColor.white
        subtitlesLabel.backgroundColor = labelBackgroundColor
        subtitlesLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitlesLabel.isHidden = true
        arView.addSubview(subtitlesLabel)

        arView.addConstraints([
            NSLayoutConstraint(item: subtitlesLabel!,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: arView,
                               attribute: .leading,
                               multiplier: constraintMultiplier,
                               constant: constraintConstant),

            NSLayoutConstraint(item: arView!,
                               attribute: .bottomMargin,
                               relatedBy: .equal,
                               toItem: subtitlesLabel,
                               attribute: .bottom,
                               multiplier: constraintMultiplier,
                               constant: constraintConstant),

            NSLayoutConstraint(item: arView!,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: subtitlesLabel,
                               attribute: .trailing,
                               multiplier: constraintMultiplier,
                               constant: constraintConstant)
        ])
    }

    private func showScene() {
        guard !isCoaching, let scene = scene else { return }

        arView.scene.addAnchor(scene.anchor)

        if let subtitles = scene.subtitles {
            showSubtitles(subtitles)
        }

        self.scene = nil
    }
}
