//
//  MirrorsExtendedObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MirrorsExtendedObject: Int {
    case empty, forbidden, marker
    case backward, forward
    init() {
        self = .empty
    }
}

struct MirrorsExtendedLaserDot {
    let p: Position
    let dir: Int
}

struct MirrorsExtendedLaser {
    var dots = [MirrorsExtendedLaserDot]()
    let number: Int
    init(n: Int) {
        number = n
    }
}

struct MirrorsExtendedGameMove {
    var p = Position()
    var obj = MirrorsExtendedObject()
}
