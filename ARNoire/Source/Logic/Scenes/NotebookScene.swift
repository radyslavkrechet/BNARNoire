//
//  NotebookScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

class NotebookScene: EvidenceSceneProtocol {
    let type = SceneType.notebook

    private var scene: Notebook.Scene!
    private var foundedClues = Set<String>()

    private weak var delegate: NotebookSceneDelegate?

    init(delegate: NotebookSceneDelegate) {
        self.delegate = delegate
    }

    func applyFoundedClues(_ foundedClues: Set<String>) {
        self.foundedClues = foundedClues
    }

    func load(completion: @escaping (HasAnchoring) -> Void) {
        Notebook.loadSceneAsync { [weak self] result in
            if case .success(let scene) = result {
                completion(scene)
                self?.setup(scene)
            }
        }
    }

    // MARK: - Private

    private func setup(_ scene: Notebook.Scene) {
        self.scene = scene

        scene.actions.showFoundedClues.onAction = { [weak self] _ in
            self?.showFoundedClues()
        }

        scene.actions.tapWife.onAction = { [weak self] _ in
            self?.delegate?.suspectWasSelected(.wife)
        }

        scene.actions.tapSecretary.onAction = { [weak self] _ in
            self?.delegate?.suspectWasSelected(.secretary)
        }

        // Determinate actions for founded clues

        let slice = scene.actions.allActions.suffix(Clue.allCases.count)
        let clueActions = Array(slice)

        Clue.allCases.enumerated().forEach {
            let clue = $0.element
            if foundedClues.contains(clue.rawValue) {
                clueActions[$0.offset].onAction = { [weak self] _ in
                    self?.delegate?.clueWasSelected(clue)
                }
            }
        }
    }

    private func showFoundedClues() {
        let optionalClues: [Clue] = [.baseballGlove, .baseballTicket, .baseball, .divorcePapers, .flowers]

        optionalClues.enumerated().forEach {
            if foundedClues.contains($0.element.rawValue) {
                scene.notifications.allNotifications[$0.offset].post()
            }
        }
    }
}
