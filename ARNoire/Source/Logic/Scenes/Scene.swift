//
//  Scene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 21.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

enum SceneType {
    case information, location(phrase: String), interrogation(dialog: String), notebook
}

protocol SceneProtocol: class {
    var type: SceneType { get }

    func load(completion: @escaping (HasAnchoring) -> Void)
}

protocol EvidenceSceneProtocol: SceneProtocol {
    func applyFoundedClues(_ foundedClues: Set<String>)
}

protocol NavigableSceneDelegate: class {
    func showNextScene()
}

protocol LocationSceneDelegate: NavigableSceneDelegate {
    func clueWasFound(_ clue: Clue)
    func objectWasFound()
}

protocol InterrogationSceneDelegate: NavigableSceneDelegate {
    func showDialog(_ dialog: String)
    func clueWasNoted(_ clue: Clue)
}

protocol NotebookSceneDelegate: class {
    func suspectWasSelected(_ suspect: Suspect)
    func clueWasSelected(_ clue: Clue)
}
