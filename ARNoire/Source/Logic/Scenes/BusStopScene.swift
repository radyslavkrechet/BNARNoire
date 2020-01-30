//
//  BusStopScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

private let clueCount = 2

class BusStopScene: SceneProtocol {
    let type = SceneType.location(phrase: "Scene.busStop.phrase".localized)

    private var scene: BusStop.Scene!
    private var foundedClues = Set<String>()

    private weak var delegate: LocationSceneDelegate?

    init(delegate: LocationSceneDelegate) {
        self.delegate = delegate
    }

    func load(completion: @escaping (HasAnchoring) -> Void) {
        BusStop.loadSceneAsync { [weak self] result in
            if case .success(let scene) = result {
                completion(scene)
                self?.setup(scene)
            }
        }
    }

    // MARK: - Private

    private func setup(_ scene: BusStop.Scene) {
        self.scene = scene

        scene.actions.tapWallet.onAction = { [weak self] _ in
            self?.process(.wallet)
        }

        scene.actions.tapKnife.onAction = { [weak self] _ in
            self?.process(.knife)
        }

        scene.actions.tapObject.onAction = { [weak self] _ in
            self?.delegate?.objectWasFound()
        }

        scene.actions.tapNext.onAction = { [weak self] _ in
            self?.delegate?.showNextScene()
        }
    }

    private func process(_ clue: Clue) {
        guard !foundedClues.contains(clue.rawValue) else { return }

        foundedClues.insert(clue.rawValue)
        delegate?.clueWasFound(clue)

        if foundedClues.count == clueCount {
            scene.notifications.showNext.post()
        }
    }
}
