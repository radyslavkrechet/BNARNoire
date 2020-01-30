//
//  Suspect.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 23.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import Foundation

enum Suspect: String {
    case wife, secretary

    var name: String {
        return "Suspect.\(rawValue).name".localized
    }
}
