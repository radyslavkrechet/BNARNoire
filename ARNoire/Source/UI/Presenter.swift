//
//  Presenter.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import ARKit

private let interrogationWifeSceneIndex = 3
private let interrogationSecretarySceneIndex = 5
private let randomPhraseRange = 0...2

protocol PresenterProtocol {
    func startExperience()
}

class Presenter: PresenterProtocol, LocationSceneDelegate, InterrogationSceneDelegate, NotebookSceneDelegate {
    private enum PhraseDestination: String {
        case Object, Notebook
    }

    private var scenes = [SceneProtocol]()
    private var currentScene: SceneProtocol!
    private var foundedClues = Set<String>()
    private var notedClues = [String: Bool]()
    private var accusation: (suspect: Suspect?, clue: Clue?) = (nil, nil)

    private weak var view: ViewProtocol?

    init(view: ViewProtocol) {
        self.view = view
    }

    // MARK: - PresenterProtocol

    func startExperience() {
        scenes = [IntroScene(delegate: self),
                  BusStopScene(delegate: self),
                  KitchenScene(delegate: self),
                  OfficeScene(delegate: self),
                  NotebookScene(delegate: self),
                  OutroScene()]

        if ARFaceTrackingConfiguration.isSupported {
            scenes.insert(InterrogationScene(suspect: .wife, delegate: self), at: interrogationWifeSceneIndex)
            scenes.insert(InterrogationScene(suspect: .secretary, delegate: self), at: interrogationSecretarySceneIndex)
        }

        startNextScene()
    }

    // MARK: - NavigableSceneDelegate

    func showNextScene() {
        startNextScene()
    }

    // MARK: - LocationSceneDelegate

    func clueWasFound(_ clue: Clue) {
        foundedClues.insert(clue.rawValue)
        view?.showSubtitles(clue.phrase)
        view?.showClue(clue.name)
    }

    func objectWasFound() {
        showPhrase(forDestination: .Object)
    }

    // MARK: - InterrogationSceneDelegate

    func showDialog(_ dialog: String) {
        view?.showSubtitles(dialog)
    }

    func clueWasNoted(_ clue: Clue) {
        if notedClues[clue.rawValue] == nil {
            // Clue was noted (first note)
            notedClues[clue.rawValue] = false
        } else if notedClues[clue.rawValue] == false {
            // Clue was found (second note)
            notedClues[clue.rawValue] = true
            clueWasFound(clue)
        }
    }

    // MARK: - NotebookSceneDelegate

    func suspectWasSelected(_ suspect: Suspect) {
        accusation.suspect = suspect
        pocessAccusation()
    }

    func clueWasSelected(_ clue: Clue) {
        accusation.clue = clue
        pocessAccusation()
    }

    // MARK: - Private

    private func startNextScene() {
        currentScene = scenes.removeFirst()
        if let evidenceScene = currentScene as? EvidenceSceneProtocol {
            evidenceScene.applyFoundedClues(foundedClues)
        }

        var trakingTarget: TrakingTarget!
        var subtitles: String?

        switch currentScene.type {
        case .information:
            trakingTarget = .wall
        case .location(let phrase):
            trakingTarget = .floor
            subtitles = phrase
        case .interrogation(let dialog):
            trakingTarget = .face
            subtitles = dialog
        case .notebook:
            trakingTarget = .desk
        }

        view?.runSession(with: trakingTarget)

        currentScene.load { [weak self] anchor in
            self?.view?.showScene(with: anchor, subtitles: subtitles)
        }
    }

    private func showPhrase(forDestination phraseDestination: PhraseDestination) {
        let index = Int.random(in: randomPhraseRange)
        let phrase = "\(phraseDestination.rawValue).phrase.\(index)".localized
        view?.showSubtitles(phrase)
    }

    private func pocessAccusation() {
        // Show suspect or clue name after first item of accusation selection

        guard let suspect = accusation.suspect, let clue = accusation.clue else {
            let name = accusation.suspect?.name ?? accusation.clue!.name
            view?.showSubtitles("\(name)...")

            return
        }

        // Show next scene or unsuccessful phrase after second item of accusation selection

        if suspect == .wife && clue == .flowers {
            startNextScene()
        } else {
            accusation = (nil, nil)
            showPhrase(forDestination: .Notebook)
        }
    }
}
