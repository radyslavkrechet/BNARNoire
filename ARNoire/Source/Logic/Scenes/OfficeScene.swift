//
//  OfficeScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

class OfficeScene: SceneProtocol {
    let type = SceneType.location(phrase: "Scene.office.phrase".localized)

    private var foundedClues = Set<String>()

    private weak var delegate: LocationSceneDelegate?

    init(delegate: LocationSceneDelegate) {
        self.delegate = delegate
    }

    func load(completion: @escaping (HasAnchoring) -> Void) {
        Office.loadSceneAsync { [weak self] result in
            if case .success(let scene) = result {
                completion(scene)
                self?.setup(scene)
            }
        }
    }

    // MARK: - Private

    private func setup(_ scene: Office.Scene) {
        scene.actions.tapBaseball.onAction = { [weak self] _ in
            self?.process(.baseball)
        }

        scene.actions.tapDivorcePapers.onAction = { [weak self] _ in
            self?.process(.divorcePapers)
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
