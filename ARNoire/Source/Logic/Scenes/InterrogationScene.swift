//
//  InterrogationScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import Foundation
import RealityKit

class InterrogationScene: EvidenceSceneProtocol {
    private enum Tactic: String {
        case goodCop, badCop
    }

    private(set) lazy var type: SceneType = {
        return SceneType.interrogation(dialog: "Interrogation.\(suspect.rawValue).\(dialogs.first!).question".localized)
    }()

    private var suspect: Suspect
    private var scene: Interrogation.Scene!
    private var dialogs = ["0", "1"]

    private weak var delegate: InterrogationSceneDelegate?

    init(suspect: Suspect, delegate: InterrogationSceneDelegate) {
        self.suspect = suspect
        self.delegate = delegate
    }

    func applyFoundedClues(_ foundedClues: Set<String>) {
        var cluesToAdd = [String]()

        switch suspect {
        case .wife:
            cluesToAdd += [Clue.baseballGlove.rawValue, Clue.baseballTicket.rawValue]
        case .secretary:
            cluesToAdd += [Clue.baseball.rawValue, Clue.divorcePapers.rawValue]
        }

        cluesToAdd.forEach {
            if foundedClues.contains($0) {
                dialogs.append($0)
            }
        }
    }

    func load(completion: @escaping (HasAnchoring) -> Void) {
        Interrogation.loadSceneAsync { [weak self] result in
            if case .success(let scene) = result {
                completion(scene)
                self?.setup(scene)
            }
        }
    }

    // MARK: - Private

    private func setup(_ scene: Interrogation.Scene) {
        self.scene = scene

        scene.actions.tapGoodCop.onAction = { [weak self] _ in
            self?.process(.goodCop)
        }

        scene.actions.tapBadCop.onAction = { [weak self] _ in
            self?.process(.badCop)
        }

        scene.actions.tapNext.onAction = { [weak self] _ in
            self?.showNextDialog()
        }
    }

    private func process(_ tactic: Tactic) {
        // Note clue in specific cases

        let isBadCopTactic = tactic == .badCop
        let isDialogAboutTicket = dialogs.first! == Clue.baseballTicket.rawValue
        let isDialogAboutBaseball = dialogs.first! == Clue.baseball.rawValue
        if isBadCopTactic && (isDialogAboutTicket || isDialogAboutBaseball) {
            delegate?.clueWasNoted(.flowers)
        }

        // If it is not last dialog then show "NEXT" and dialog

        var dialog = "Interrogation.\(suspect.rawValue).\(dialogs.first!).\(tactic.rawValue)".localized

        guard dialogs.first == dialogs.last else {
            scene.notifications.showNext.post()
            delegate?.showDialog(dialog)

            return
        }

        // else hide "GOOD COP" and "BAD COP", show last dialog with conclusion and switch scene after few seconds

        scene.notifications.hideGoodBadCop.post()

        dialog += "Interrogation.\(suspect.rawValue).conclusion".localized
        delegate?.showDialog(dialog)

        DispatchQueue.main.asyncAfter(deadline: .now() + longSubtitlesDelay) { [weak self] in
            self?.delegate?.showNextScene()
        }
    }

    private func showNextDialog() {
        dialogs.removeFirst()

        scene.notifications.showGoodBadCop.post()
        delegate?.showDialog("Interrogation.\(suspect.rawValue).\(dialogs.first!).question".localized)
    }
}
