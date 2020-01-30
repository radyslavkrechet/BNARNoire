//
//  Clue.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import Foundation

enum Clue: String, CaseIterable {
    case wallet, knife, baseballGlove, baseballTicket, baseball, divorcePapers, flowers

    var name: String {
        return "Clue.\(rawValue).name".localized
    }
    var phrase: String {
        return "Clue.\(rawValue).phrase".localized
    }
}
