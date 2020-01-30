//
//  OutroScene.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 23.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import RealityKit

class OutroScene: SceneProtocol {
    let type = SceneType.information

    func load(completion: @escaping (HasAnchoring) -> Void) {
        Outro.loadSceneAsync { result in
            if case .success(let scene) = result {
                completion(scene)
            }
        }
    }
}
