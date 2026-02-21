//
//  UnreliableHintsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum UnreliableHintsObject: Int {
    case normal, forbidden, marker, shaded
    init() {
        self = .normal
    }
    var isShaded: Bool { return self == .shaded }
}

struct UnreliableHintsHint {
    var num = 0
    var dir = 0
}

struct UnreliableHintsGameMove {
    var p = Position()
    var obj = UnreliableHintsObject()
}

