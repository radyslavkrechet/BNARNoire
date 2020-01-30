//
//  IntroScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 21.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

class IntroScene: SceneProtocol {
    let type = SceneType.information

    private weak var delegate: NavigableSceneDelegate?

    init(delegate: NavigableSceneDelegate) {
        self.delegate = delegate
    }

    func load(completion: @escaping (HasAnchoring) -> Void) {
        Intro.loadSceneAsync { [weak self] result in
            if case .success(let scene) = result {
                completion(scene)
                self?.setup(scene)
            }
        }
    }

    // MARK: - Private

    private func setup(_ scene: Intro.Scene) {
        scene.actions.tapNext.onAction = { [weak self] _ in
            self?.delegate?.showNextScene()
        }
    }
}
