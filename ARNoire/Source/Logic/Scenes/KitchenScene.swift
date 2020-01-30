//
//  KitchenScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

class KitchenScene: SceneProtocol {
    let type = SceneType.location(phrase: "Scene.kitchen.phrase".localized)

    private var foundedClues = Set<String>()

    private weak var delegate: LocationSceneDelegate?
    
    init(delegate: LocationSceneDelegate) {
        self.delegate = delegate
    }

    func load(completion: @escaping (HasAnchoring) -> Void) {
        Kitchen.loadSceneAsync { [weak self] result in
            if case .success(let scene) = result {
                completion(scene)
                self?.setup(scene)
            }
        }
    }

    // MARK: - Private

    private func setup(_ scene: Kitchen.Scene) {
        scene.actions.tapBaseballGlove.onAction = { [weak self] _ in
            self?.process(.baseballGlove)
        }
        
        scene.actions.tapBaseballTicket.onAction = { [weak self] _ in
            self?.process(.baseballTicket)
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
    }
}
