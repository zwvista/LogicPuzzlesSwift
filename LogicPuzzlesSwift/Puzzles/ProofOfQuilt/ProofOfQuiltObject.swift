//
//  ProofOfQuiltObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ProofOfQuiltObject: Int {
    case empty, filled, forbidden, marker
    case triangleA, triangleB, triangleC, triangleD
    init() {
        self = .empty
    }
    var isBlank: Bool {
        [.empty, .forbidden, .marker].contains(self)
    }
    var isTriangle: Bool {
        [.triangleA, .triangleB, .triangleC, .triangleD].contains(self)
    }
}

struct ProofOfQuiltGameMove {
    var p = Position()
    var obj = ProofOfQuiltObject()
}
