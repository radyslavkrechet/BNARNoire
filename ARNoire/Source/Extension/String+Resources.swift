//
//  String+Resources.swift
//  ARNoire
//
//  Created by Radyslav Krechet on 22.01.2020.
//  Copyright © 2020 Radyslav Krechet. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
